import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/auth_models.dart';
import '../../features/auth/presentation/auth_controller.dart';

/// The shared Dio instance, pre-configured with the base URL and the
/// authentication interceptor (attaches the Bearer token, refreshes on 401).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  ));
  dio.interceptors.add(_AuthInterceptor(ref));
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this.ref);
  final Ref ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await ref.read(tokenStorageProvider).accessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthCall = err.requestOptions.path.contains('/auth/');
    if (err.response?.statusCode == 401 && !isAuthCall) {
      if (await _refresh()) {
        try {
          final token = await ref.read(tokenStorageProvider).accessToken();
          final req = err.requestOptions;
          req.headers['Authorization'] = 'Bearer $token';
          final retry = await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)).fetch(req);
          return handler.resolve(retry);
        } catch (_) {/* fall through */}
      } else {
        await ref.read(tokenStorageProvider).clear();
        ref.read(authControllerProvider.notifier).forceLogout();
      }
    }
    handler.next(err);
  }

  /// Uses the refresh token to obtain a new access token. Uses a bare Dio to
  /// avoid recursing through this interceptor.
  Future<bool> _refresh() async {
    final rt = await ref.read(tokenStorageProvider).refreshToken();
    if (rt == null) return false;
    try {
      final bare = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final resp = await bare.post('/api/auth/refresh', data: {'refresh_token': rt});
      await ref.read(tokenStorageProvider).save(AuthTokens.fromJson(resp.data as Map<String, dynamic>));
      return true;
    } catch (_) {
      return false;
    }
  }
}

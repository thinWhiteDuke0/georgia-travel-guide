import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<AuthTokens> register(String email, String password, String fullName) async {
    try {
      final r = await _dio.post('/api/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });
      return AuthTokens.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<AuthTokens> login(String email, String password) async {
    try {
      final r = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      return AuthTokens.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<Profile> me() async {
    try {
      final r = await _dio.get('/api/users/me');
      return Profile.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<Profile> updateMe({required String fullName, String avatarUrl = ''}) async {
    try {
      final r = await _dio.put('/api/users/me', data: {
        'full_name': fullName,
        'avatar_url': avatarUrl,
      });
      return Profile.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}

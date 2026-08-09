import 'package:dio/dio.dart';

/// A user-friendly wrapper around Dio errors.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  factory ApiException.from(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      final data = error.response?.data;
      String msg = 'ქსელის შეცდომა. სცადეთ თავიდან.';
      if (data is Map && data['error'] is String) {
        msg = data['error'] as String;
      } else if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        msg = 'სერვერთან დაკავშირება ვერ მოხერხდა.';
      }
      return ApiException(msg, statusCode: code);
    }
    return ApiException('მოულოდნელი შეცდომა.');
  }
}

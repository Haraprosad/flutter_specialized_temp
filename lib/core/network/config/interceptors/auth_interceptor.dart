import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/storage/secure_storage_manager.dart';
import 'package:flutter_specialized_temp/core/storage/storage_keys.dart';

/// Injects the Authorization Bearer token into every outgoing request.
///
/// Public endpoints (login, register, refresh) are skipped — they don't need
/// a token and sending one would cause confusion on the server side.
///
/// The token is read from [SecureStorageManager] on every request so that a
/// freshly-refreshed token is always picked up without restarting the interceptor.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);
  final SecureStorageManager _secureStorage;

  /// Paths that do NOT need an Authorization header.
  static const List<String> _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicPaths.any((path) => options.path.contains(path));

    if (!isPublic) {
      try {
        final token = await _secureStorage.readSecureData(
          StorageKeys.authToken,
        );
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        AppLogger.w(
          message: 'AuthInterceptor: failed to read access token',
          error: e,
        );
      }
    }

    return handler.next(options);
  }
}

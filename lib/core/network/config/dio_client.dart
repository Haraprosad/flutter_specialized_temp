import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/auth_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/error_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/retry_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/token_refresh_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/constants/network_constants.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/storage/secure_storage_manager.dart';
import 'package:flutter_specialized_temp/flavors/env_config.dart';
import 'package:injectable/injectable.dart';

/// Central HTTP client setup using Dio.
///
/// Interceptor chain (in execution order for requests, same order for errors):
///   1. RetryInterceptor     — retries on timeouts and 5xx
///   2. AuthInterceptor      — injects Authorization: Bearer <token>
///   3. TokenRefreshInterceptor — handles 401 by refreshing the token and retrying
///   4. ErrorInterceptor     — logs all remaining errors
///   5. LogInterceptor       — full request/response logging (debug only)
@lazySingleton
class DioClient {
  DioClient(this._connectionManager, this._secureStorage, this._appStorage) {
    _dio = _createDioClient();
  }
  final ConnectionManager _connectionManager;
  final SecureStorageManager _secureStorage;
  final AppStorage _appStorage;

  late final Dio _dio;

  Dio get client => _dio;

  Dio _createDioClient() {
    final envConfig = EnvConfig.instance;
    final dio = Dio(
      BaseOptions(
        baseUrl: envConfig.baseUrl,
        connectTimeout: NetworkConstants.connectionTimeout,
        receiveTimeout: NetworkConstants.receiveTimeout,
        sendTimeout: NetworkConstants.sendTimeout,
        headers: {
          'Content-Type': NetworkConstants.contentType,
          'Accept': NetworkConstants.accept,
        },
      ),
    );

    final retryInterceptor = RetryInterceptor(
      connectionManager: _connectionManager,
    );
    final tokenRefreshInterceptor = TokenRefreshInterceptor(
      appStorage: _appStorage,
    );

    dio.interceptors.addAll([
      retryInterceptor,
      AuthInterceptor(_secureStorage),
      tokenRefreshInterceptor,
      ErrorInterceptor(),
      if (!kReleaseMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint('DIO: $o'),
        ),
    ]);

    // Wire Dio back into interceptors that need to replay requests.
    retryInterceptor.dio = dio;
    tokenRefreshInterceptor.dio = dio;

    return dio;
  }
}

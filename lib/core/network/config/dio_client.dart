// dio_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';
import 'package:flutter_specialized_temp/core/network/constants/network_constants.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/connectivity_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/error_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/retry_interceptor.dart';
import 'package:flutter_specialized_temp/flavors/env_config.dart';

/// Central HTTP client setup using Dio.
///
/// This configures a single Dio instance with all the interceptors we need
/// for error handling, retries, and connectivity checks. Gets injected
/// wherever we need to make API calls.
@lazySingleton
class DioClient {
  final ConnectionManager _connectionManager;
  late final Dio _dio;

  DioClient(this._connectionManager) {
    _dio = _createDioClient();
  }

  Dio get client => _dio;

  /// Builds the Dio client with base URL, timeouts, and all our interceptors
  Dio _createDioClient() {
    final EnvConfig envConfig = EnvConfig.instance;
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

    // Chain interceptors for retry logic and error handling
    // Note: ConnectivityInterceptor is disabled since we use reactive monitoring instead
    dio.interceptors.addAll([
      // ConnectivityInterceptor(_connectionManager), // Not needed - using reactive monitoring instead
      RetryInterceptor(
        connectionManager:
            _connectionManager, // Provides instant offline detection
      ), // Automatic retry with exponential backoff
      ErrorInterceptor(),
      // if (!kReleaseMode)
      //   LogInterceptor(
      //     requestBody: true,
      //     responseBody: true,
      //     logPrint: (o) => debugPrint('DIO: $o'),
      //   ),
    ]);

    return dio;
  }
}

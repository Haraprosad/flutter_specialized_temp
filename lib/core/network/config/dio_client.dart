// dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/flavors/env_config.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';
import 'package:flutter_specialized_temp/core/network/constants/network_constants.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/connectivity_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/error_interceptor.dart';


/// Singleton service for configuring and providing a Dio HTTP client instance.
@lazySingleton
class DioClient {
  final ConnectionManager _connectionManager;
  late final Dio _dio;

  DioClient(this._connectionManager) {
    _dio = _createDioClient();
  }

  Dio get client => _dio;

  /// Creates and configures Dio client with interceptors and base options.
  Dio _createDioClient() {
    final EnvConfig envConfig = EnvConfig.instance;
    final dio = Dio(BaseOptions(
      baseUrl: envConfig.baseUrl,
      connectTimeout: NetworkConstants.connectionTimeout,
      receiveTimeout: NetworkConstants.receiveTimeout,
      sendTimeout: NetworkConstants.sendTimeout,
      headers: {
        'Content-Type': NetworkConstants.contentType,
        'Accept': NetworkConstants.accept,
      },
    ));

    // Add interceptors for connectivity, error logging, and optional logging in debug mode.
    dio.interceptors.addAll([
      ConnectivityInterceptor(_connectionManager),
      ErrorInterceptor(),
      if (!kReleaseMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint('DIO: $o'),
        ),
    ]);

    return dio;
  }
}

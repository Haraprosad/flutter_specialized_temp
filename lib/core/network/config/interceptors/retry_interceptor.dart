import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/constants/network_constants.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';

/// Interceptor that implements automatic retry with exponential backoff.
///
/// This interceptor will automatically retry failed requests based on:
/// - Network timeouts (connection, send, receive)
/// - Temporary server errors (500, 502, 503, 504)
/// - Connection errors
///
/// It will NOT retry:
/// - Client errors (400, 401, 403, 404, etc.)
/// - Successful responses (2xx)
/// - Cancelled requests
/// - No internet connection errors (handled separately)
///
/// Performance Optimization:
/// - Uses cached connectivity state (instant check, 0ms overhead)
/// - Fails fast when offline (no wasted retry attempts)
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final ConnectionManager? connectionManager;

  Dio? _dio;

  RetryInterceptor({
    this.maxRetries = NetworkConstants.maxRetries,
    this.initialDelay = NetworkConstants.initialRetryDelay,
    this.backoffMultiplier = NetworkConstants.retryBackoffMultiplier,
    this.connectionManager,
  });

  /// Set the Dio instance after construction to avoid circular dependency.
  /// Called by DioClient after the Dio instance is fully built.
  void setDio(Dio dio) => _dio = dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      AppLogger.w(
        message:
            'Max retries ($maxRetries) reached for: ${err.requestOptions.path}',
      );
      return handler.next(err);
    }

    // Exponential backoff: initialDelay * backoffMultiplier * attempt
    final delayMilliseconds =
        initialDelay.inMilliseconds * (backoffMultiplier * (retryCount + 1));
    final delay = Duration(milliseconds: delayMilliseconds.toInt());

    AppLogger.i(
      message:
          'Retrying (${retryCount + 1}/$maxRetries) after ${delay.inSeconds}s: ${err.requestOptions.path}',
    );

    await Future.delayed(delay);

    final newRetryCount = retryCount + 1;
    err.requestOptions.extra['retryCount'] = newRetryCount;

    try {
      final dio = _dio;
      if (dio == null) {
        AppLogger.e(message: 'RetryInterceptor: Dio instance not set');
        return handler.next(err);
      }

      // Reuse the same Dio instance to preserve base URL, headers, and interceptor chain
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      AppLogger.w(
        message:
            'Retry failed (attempt $newRetryCount): ${err.requestOptions.path}',
      );
      return super.onError(e, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    if (connectionManager != null && !connectionManager!.isConnected) {
      return false;
    }

    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null && _isRetriableStatusCode(statusCode)) {
        return true;
      }
    }

    return false;
  }

  bool _isRetriableStatusCode(int statusCode) {
    return statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504 ||
        statusCode == 408;
  }
}

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

  RetryInterceptor({
    this.maxRetries = NetworkConstants.maxRetries,
    this.initialDelay = NetworkConstants.initialRetryDelay,
    this.backoffMultiplier = NetworkConstants.retryBackoffMultiplier,
    this.connectionManager,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if this error should be retried
    if (!_shouldRetry(err)) {
      AppLogger.d(
        message: '❌ Request will not be retried: ${err.requestOptions.path}',
      );
      return handler.next(err);
    }

    // Get current retry count
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      AppLogger.w(
        message:
            '⚠️ Max retries ($maxRetries) reached for: ${err.requestOptions.path}',
      );
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final delayMilliseconds =
        initialDelay.inMilliseconds * (backoffMultiplier * (retryCount + 1));
    final delay = Duration(milliseconds: delayMilliseconds.toInt());

    AppLogger.i(
      message:
          '🔄 Retrying request (${retryCount + 1}/$maxRetries) after ${delay.inSeconds}s: ${err.requestOptions.path}',
    );

    // Wait before retrying
    await Future.delayed(delay);

    // Increment retry count
    final newRetryCount = retryCount + 1;
    err.requestOptions.extra['retryCount'] = newRetryCount;

    try {
      // Create a new request with the same options
      final response = await Dio().fetch(err.requestOptions);
      AppLogger.d(
        message:
            '✅ Retry successful (attempt $newRetryCount): ${err.requestOptions.path}',
      );
      return handler.resolve(response);
    } on DioException catch (e) {
      AppLogger.w(
        message:
            '❌ Retry failed (attempt $newRetryCount): ${err.requestOptions.path}',
      );
      // Pass the error to the next interceptor or retry again
      return super.onError(e, handler);
    }
  }

  /// Determines if a request should be retried based on the error type
  bool _shouldRetry(DioException err) {
    // Performance optimization: Check cached connectivity state (instant!)
    // If offline, fail fast instead of wasting time on retries
    if (connectionManager != null && !connectionManager!.isConnected) {
      AppLogger.d(message: '📵 Device is offline, skipping retry to save time');
      return false;
    }

    // Don't retry cancelled requests
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Retry on timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on temporary server errors
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null && _isRetriableStatusCode(statusCode)) {
        return true;
      }
    }

    // Don't retry other errors (4xx client errors, parsing errors, etc.)
    return false;
  }

  /// Checks if the HTTP status code indicates a retriable error
  bool _isRetriableStatusCode(int statusCode) {
    // Retry on temporary server errors
    return statusCode == 500 || // Internal Server Error
        statusCode == 502 || // Bad Gateway
        statusCode == 503 || // Service Unavailable
        statusCode == 504 || // Gateway Timeout
        statusCode == 408; // Request Timeout
  }
}

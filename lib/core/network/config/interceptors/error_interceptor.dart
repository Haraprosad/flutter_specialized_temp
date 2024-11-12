import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/reporters/error_reporter.dart';

/// Interceptor that logs errors using an ErrorReporter.
class ErrorInterceptor extends Interceptor {
  final ErrorReporter errorReporter;

  ErrorInterceptor(this.errorReporter);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    errorReporter.recordError(
      err,
      err.stackTrace,
      metadata: {
        'url': err.requestOptions.uri.toString(),
        'method': err.requestOptions.method,
        'responseCode': err.response?.statusCode,
        'error': err.error.toString(),
      },
    );
    handler.next(err);
  }
}

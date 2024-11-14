import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/enums/custom_error_type.dart';


/// Interceptor that logs errors using an ErrorReporter.
class ErrorInterceptor extends Interceptor {

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error != CustomErrorType.noInternet) {
      AppLogger.e(
        message: "ErrorInterceptor",
        error: err,
        stackTrace: err.stackTrace,
        metadata: {
          'url': err.requestOptions.uri.toString(),
          'method': err.requestOptions.method,
          'responseCode': err.response?.statusCode,
          'error': err.error.toString(),
        },
      );
    }
    handler.next(err);
  }
}

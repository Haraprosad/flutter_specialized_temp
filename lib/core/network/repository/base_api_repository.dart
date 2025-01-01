import 'package:flutter_specialized_temp/core/network/error_handling/network_error_handler.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';

abstract class BaseApiRepository {
  final NetworkErrorHandler _errorHandler;

  BaseApiRepository(this._errorHandler);

  Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      final result = await apiCall();
      return ApiSuccess(result);
    } catch (error, stackTrace) {
      final failure = _errorHandler.handleError(error, stackTrace);
      return ApiFailure(failure);
    }
  }
}
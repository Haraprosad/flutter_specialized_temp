import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';

/// Represents the result of an API call, either success or failure.
sealed class ApiResult<T> {
  const ApiResult();
}

/// Represents a successful API call result.
final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

/// Represents a failed API call result.
final class ApiFailure<T> extends ApiResult<T> {
  final ApiCallFailureModel failure;
  const ApiFailure(this.failure);
}

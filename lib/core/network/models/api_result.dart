import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';

/// Wraps API responses in a type-safe way - it's either success or failure.
///
/// Using sealed classes means Dart forces us to handle both cases,
/// so we can't forget to check for errors.
sealed class ApiResult<T> {
  const ApiResult();
}

/// The API call worked and we got data back
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

/// The API call failed for some reason - network error, server error, etc.
final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.failure);
  final ApiCallFailureModel failure;
}

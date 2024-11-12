// base_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_specialized_temp/core/network/bloc/base_bloc_state.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';

/// Base class for handling API calls in a BLoC, providing error and success management.
abstract class BaseBloc<Event, State extends BaseBlocState>
    extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// Executes an API call and handles loading, success, and error states.
  ///
  /// [apiCall] The API request function to execute.
  /// [onSuccess] Callback triggered when the request is successful.
  /// [onError] Optional callback triggered in case of an error.
  /// [emit] Function to update the state.
  /// [showLoader] Whether to show a loading indicator during the request.
  @protected
  Future<void> handleApiCall<T>({
    required Future<ApiResult<T>> Function() apiCall,
    required void Function(T data) onSuccess,
    void Function(ApiCallFailureModel failure)? onError,
    required Emitter<State> emit,
    bool showLoader = true,
  }) async {
    try {
      // Show loading state if needed
      if (showLoader) {
        emit(state.copyWith(isLoading: true, failure: null) as State);
      }

      // Perform the API call
      final result = await apiCall();

      // Handle success response
      if (result is ApiSuccess<T>) {
        onSuccess(result.data);
      }
      // Handle error response
      else if (result is ApiFailure<T>) {
        onError?.call(result.failure);
        emit(state.copyWith(failure: result.failure) as State);
      }
    } finally {
      // Hide loading state
      if (showLoader) {
        emit(state.copyWith(isLoading: false) as State);
      }
    }
  }
}

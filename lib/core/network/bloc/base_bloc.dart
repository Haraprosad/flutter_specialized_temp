// base_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_specialized_temp/core/network/bloc/base_bloc_state.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';

/// Base class that simplifies API calls in BLoCs with built-in error handling.
///
/// Extend this instead of the regular Bloc to get automatic loading states
/// and standardized error handling for all your API calls.
abstract class BaseBloc<Event, State extends BaseBlocState>
    extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// Makes an API call and handles all the loading/success/error states automatically.
  ///
  /// This takes care of showing loaders, handling errors, and calling your success
  /// callback when everything works. You just need to focus on what happens with the data.
  ///
  /// [apiCall] - The actual API request you want to make
  /// [onSuccess] - What to do when the API returns data successfully
  /// [onError] - Optional callback if you need custom error handling
  /// [emit] - State emitter from your event handler
  /// [showLoader] - Set to false if you don't want to show loading spinner
  @protected
  Future<void> handleApiCall<T>({
    required Future<ApiResult<T>> Function() apiCall,
    required void Function(T data) onSuccess,
    required Emitter<State> emit,
    void Function(ApiCallFailureModel failure)? onError,
    bool showLoader = true,
  }) async {
    // Turn on the loading spinner if needed
    if (showLoader) {
      emit(state.copyWith(isLoading: true) as State);
    }

    // Actually make the API call
    final result = await apiCall();

    // Check what we got back and handle it
    if (result is ApiSuccess<T>) {
      onSuccess(result.data);
    } else if (result is ApiFailure<T>) {
      onError?.call(result.failure);
      emit(state.copyWith(isLoading: false, failure: result.failure) as State);
    }
  }
}

// base_bloc_state.dart

import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';

/// Base class for all BLoC states with loading and error handling properties.
abstract class BaseBlocState {
  const BaseBlocState({this.isLoading = false, this.failure});

  /// Indicates if an API request is currently in progress.
  final bool isLoading;

  /// Contains any error details related to network requests.
  final ApiCallFailureModel? failure;

  /// Returns a copy of the state with updated properties.
  /// Useful for creating modified versions of the state.
  BaseBlocState copyWith({bool? isLoading, ApiCallFailureModel? failure});
}

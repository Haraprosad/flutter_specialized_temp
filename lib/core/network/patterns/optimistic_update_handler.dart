import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';

/// Optimistic update pattern for instant UI feedback
///
/// Flow:
/// 1. Update local state/UI immediately (optimistic)
/// 2. Execute API call in background
/// 3. On success: Confirm change (UI already updated)
/// 4. On failure: Rollback change + show retry option
///
/// Benefits:
/// - Instant UI response (perceived performance)
/// - Better UX (feels faster)
/// - Graceful error handling with rollback
class OptimisticUpdateHandler<T> {
  /// Execute optimistic update
  ///
  /// @param optimisticUpdate: Function to update local state immediately
  /// @param apiCall: Function to execute API call in background
  /// @param onSuccess: Callback when API call succeeds
  /// @param onFailure: Callback when API call fails (for rollback)
  /// @param rollback: Function to rollback local state on failure
  static Future<OptimisticUpdateResult<T>> execute<T>({
    required Future<void> Function() optimisticUpdate,
    required Future<ApiResult<T>> Function() apiCall,
    required Future<void> Function(T data) onSuccess,
    required Future<void> Function(dynamic error) onFailure,
    required Future<void> Function() rollback,
  }) async {
    try {
      AppLogger.i(message: '⚡ Starting optimistic update...');

      // Step 1: Apply optimistic update immediately
      await optimisticUpdate();
      AppLogger.d(message: '✅ Optimistic update applied to UI');

      // Step 2: Execute API call in background
      AppLogger.d(message: '🌐 Executing API call in background...');
      final result = await apiCall();

      if (result is ApiSuccess<T>) {
        // Step 3: Success - confirm the change
        AppLogger.i(message: '✅ API call successful, confirming update');
        await onSuccess(result.data);
        return OptimisticUpdateResult.success(result.data);
      } else if (result is ApiFailure<T>) {
        // Step 4: Failure - rollback the optimistic update
        AppLogger.w(
          message: '❌ API call failed, rolling back optimistic update',
        );
        await rollback();
        await onFailure(result.failure);
        return OptimisticUpdateResult.failure(
          result.failure.translatedMessage,
          canRetry: true,
        );
      }

      throw Exception('Unknown ApiResult type');
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Optimistic update error',
        error: e,
        stackTrace: stackTrace,
      );
      // Rollback on any error
      await rollback();
      await onFailure(e);
      return OptimisticUpdateResult.failure('An unexpected error occurred');
    }
  }
}

/// Result of an optimistic update operation
class OptimisticUpdateResult<T> {
  const OptimisticUpdateResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.canRetry = false,
  });

  factory OptimisticUpdateResult.success(T data) {
    return OptimisticUpdateResult._(data: data, isSuccess: true);
  }

  factory OptimisticUpdateResult.failure(
    String errorMessage, {
    bool canRetry = false,
  }) {
    return OptimisticUpdateResult._(
      isSuccess: false,
      errorMessage: errorMessage,
      canRetry: canRetry,
    );
  }
  final T? data;
  final bool isSuccess;
  final String? errorMessage;
  final bool canRetry;

  bool get hasError => !isSuccess;
  bool get shouldShowRetry => hasError && canRetry;
}

/// Mixin for adding optimistic update capabilities to repositories
mixin OptimisticUpdateMixin {
  /// Execute optimistic transaction creation
  Future<OptimisticUpdateResult<T>> executeOptimistic<T>({
    required Future<void> Function() applyOptimisticChange,
    required Future<ApiResult<T>> Function() performApiCall,
    required Future<void> Function(T data) confirmChange,
    required Future<void> Function() revertChange,
    required Future<void> Function(dynamic error) handleError,
  }) async {
    return OptimisticUpdateHandler.execute(
      optimisticUpdate: applyOptimisticChange,
      apiCall: performApiCall,
      onSuccess: confirmChange,
      onFailure: handleError,
      rollback: revertChange,
    );
  }
}

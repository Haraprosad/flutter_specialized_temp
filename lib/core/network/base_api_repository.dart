import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/network_error_handler.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';

/// Lightweight base class for feature repositories that need standardised
/// error handling and logging without the full [ScalableBaseRepository]
/// complexity (circuit breaker, batching, multi-tier cache).
///
/// Extend this for simple CRUD repositories. Extend [ScalableBaseRepository]
/// when you need caching, request batching, or circuit breaking.
///
/// Example:
/// ```dart
/// @LazySingleton(as: TaskRepository)
/// class TaskRepositoryImpl extends BaseApiRepository implements TaskRepository {
///   final TaskRemoteDatasource _remote;
///
///   TaskRepositoryImpl(this._remote, super.errorHandler);
///
///   @override
///   Future<ApiResult<List<TaskEntity>>> getTasks() => safeApiCall(
///     tag: 'getTasks',
///     call: () async {
///       final models = await _remote.getTasks();
///       return models.map((m) => m.toEntity()).toList();
///     },
///   );
/// }
/// ```
abstract class BaseApiRepository {
  final NetworkErrorHandler _errorHandler;

  const BaseApiRepository(this._errorHandler);

  /// Executes [call] and wraps the result in [ApiResult].
  ///
  /// On success → [ApiSuccess] with the returned value.
  /// On any error → logs via [AppLogger] and returns [ApiFailure].
  ///
  /// [tag] identifies the call in log output (defaults to the class name).
  Future<ApiResult<T>> safeApiCall<T>({
    required Future<T> Function() call,
    String? tag,
  }) async {
    final label = tag ?? runtimeType.toString();
    try {
      final result = await call();
      AppLogger.d(message: '✅ $label succeeded');
      return ApiSuccess(result);
    } catch (error, stackTrace) {
      AppLogger.e(
        message: '❌ $label failed',
        error: error,
        stackTrace: stackTrace,
      );
      final failure = _errorHandler.handleError(error, stackTrace);
      return ApiFailure(failure);
    }
  }
}

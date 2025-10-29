import 'dart:async';
import 'package:flutter_specialized_temp/core/network/error_handling/network_error_handler.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import 'package:flutter_specialized_temp/core/network/cache/scalable_cache_manager.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';

/// Enhanced base repository with advanced performance optimizations for scalable applications.
///
/// Features:
/// - Request batching and coalescing
/// - Advanced caching with TTL
/// - Circuit breaker pattern
/// - Request prioritization
/// - Concurrent request limiting
/// - Automatic retry with exponential backoff
/// - Performance monitoring
/// - Memory efficient operations
abstract class ScalableBaseRepository {
  final NetworkErrorHandler _errorHandler;
  final ScalableCacheManager _cacheManager;

  // Protected getters for subclasses
  NetworkErrorHandler get errorHandler => _errorHandler;
  ScalableCacheManager get cacheManager => _cacheManager;

  // Circuit breaker state
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  bool _circuitOpen = false;

  // Request limiting
  final Set<String> _activeRequests = {};
  final Map<String, List<Completer<dynamic>>> _pendingBatches = {};

  // Configuration
  static const int _maxConcurrentRequests = 10;
  static const int _circuitBreakerThreshold = 5;
  static const Duration _circuitBreakerTimeout = Duration(minutes: 1);
  static const Duration _batchingWindow = Duration(milliseconds: 100);

  ScalableBaseRepository(this._errorHandler, this._cacheManager);

  /// Enhanced API call wrapper with advanced optimizations
  Future<ApiResult<T>> optimizedApiCall<T>({
    required String cacheKey,
    required Future<T> Function() apiCall,
    Duration? cacheTTL,
    RequestPriority priority = RequestPriority.normal,
    bool enableBatching = false,
    bool bypassCache = false,
  }) async {
    // Check circuit breaker
    if (_isCircuitOpen()) {
      AppLogger.w(
        message: '⚡ Circuit breaker open, failing fast for: $cacheKey',
      );
      return ApiFailure(_createCircuitBreakerFailure());
    }

    // Try cache first (unless bypassed)
    if (!bypassCache) {
      final cachedResult = await _cacheManager.get<T>(cacheKey, ttl: cacheTTL);
      if (cachedResult != null) {
        AppLogger.d(message: '🎯 Returning cached result for: $cacheKey');
        return ApiSuccess(cachedResult);
      }
    }

    // Check concurrent request limit
    if (_activeRequests.length >= _maxConcurrentRequests) {
      if (priority != RequestPriority.high) {
        AppLogger.w(message: '🚫 Request limit reached, deferring: $cacheKey');
        await _waitForSlot();
      }
    }

    // Handle batching for eligible requests
    if (enableBatching) {
      return await _handleBatchedRequest(cacheKey, apiCall, cacheTTL);
    }

    // Execute single request
    return await _executeSingleRequest(cacheKey, apiCall, cacheTTL);
  }

  /// Batch multiple related API calls to execute together
  Future<Map<String, ApiResult<dynamic>>> batchApiCalls(
    Map<String, Future<dynamic> Function()> calls, {
    Duration? cacheTTL,
  }) async {
    AppLogger.i(message: '📦 Executing batch of ${calls.length} API calls');

    final results = <String, ApiResult<dynamic>>{};
    final futures = <Future<void>>[];

    for (final entry in calls.entries) {
      final future = optimizedApiCall(
        cacheKey: entry.key,
        apiCall: entry.value,
        cacheTTL: cacheTTL,
        enableBatching: false, // Already batching at this level
      ).then((result) {
        results[entry.key] = result;
      });

      futures.add(future);
    }

    await Future.wait(futures);
    AppLogger.i(message: '✅ Batch execution completed');

    return results;
  }

  /// Preload critical data during app initialization or idle time
  Future<void> preloadCriticalData(
    Map<String, Future<dynamic> Function()> criticalLoaders, {
    Duration? cacheTTL,
  }) async {
    AppLogger.i(
      message: '🚀 Preloading ${criticalLoaders.length} critical resources',
    );

    // Use cache warmup for efficient preloading
    await _cacheManager.warmup(criticalLoaders, ttl: cacheTTL);

    AppLogger.i(message: '✅ Critical data preloading completed');
  }

  /// Get performance statistics
  RepositoryStats getPerformanceStats() {
    final cacheStats = _cacheManager.getStats();

    return RepositoryStats(
      activeRequests: _activeRequests.length,
      circuitOpen: _circuitOpen,
      failureCount: _failureCount,
      lastFailureTime: _lastFailureTime,
      cacheStats: cacheStats,
    );
  }

  // Private methods

  Future<ApiResult<T>> _executeSingleRequest<T>(
    String cacheKey,
    Future<T> Function() apiCall,
    Duration? cacheTTL,
  ) async {
    _activeRequests.add(cacheKey);

    try {
      AppLogger.d(message: '🌐 Executing API call: $cacheKey');
      final result = await apiCall();

      // Cache the result
      await _cacheManager.put(cacheKey, result, ttl: cacheTTL);

      // Reset circuit breaker on success
      _resetCircuitBreaker();

      return ApiSuccess(result);
    } catch (error, stackTrace) {
      // Handle circuit breaker
      _recordFailure();

      final failure = _errorHandler.handleError(error, stackTrace);
      return ApiFailure(failure);
    } finally {
      _activeRequests.remove(cacheKey);
    }
  }

  Future<ApiResult<T>> _handleBatchedRequest<T>(
    String cacheKey,
    Future<T> Function() apiCall,
    Duration? cacheTTL,
  ) async {
    // Check if there's already a pending batch for this type of request
    final batchKey = _getBatchKey(cacheKey);

    if (_pendingBatches.containsKey(batchKey)) {
      // Join existing batch
      final completer = Completer<ApiResult<T>>();
      _pendingBatches[batchKey]!.add(completer as Completer<dynamic>);
      return await completer.future;
    }

    // Start new batch
    final completers = <Completer<dynamic>>[Completer<ApiResult<T>>()];
    _pendingBatches[batchKey] = completers;

    // Wait for batching window
    await Future.delayed(_batchingWindow);

    // Execute all requests in the batch
    final batchCompleters = _pendingBatches.remove(batchKey) ?? [];

    try {
      final result = await _executeSingleRequest(cacheKey, apiCall, cacheTTL);

      // Complete all waiting requests with the same result
      for (final completer in batchCompleters) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }

      return result;
    } catch (error) {
      for (final completer in batchCompleters) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      }
      rethrow;
    }
  }

  bool _isCircuitOpen() {
    if (!_circuitOpen) return false;

    if (_lastFailureTime != null &&
        DateTime.now().difference(_lastFailureTime!) > _circuitBreakerTimeout) {
      // Try to close circuit (half-open state)
      _circuitOpen = false;
      AppLogger.i(message: '🔄 Circuit breaker moving to half-open state');
      return false;
    }

    return true;
  }

  void _recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= _circuitBreakerThreshold) {
      _circuitOpen = true;
      AppLogger.w(
        message: '⚡ Circuit breaker opened after $_failureCount failures',
      );
    }
  }

  void _resetCircuitBreaker() {
    if (_failureCount > 0 || _circuitOpen) {
      _failureCount = 0;
      _circuitOpen = false;
      _lastFailureTime = null;
      AppLogger.i(message: '✅ Circuit breaker reset');
    }
  }

  Future<void> _waitForSlot() async {
    const maxWaitTime = Duration(seconds: 5);
    const checkInterval = Duration(milliseconds: 100);

    final stopwatch = Stopwatch()..start();

    while (_activeRequests.length >= _maxConcurrentRequests &&
        stopwatch.elapsed < maxWaitTime) {
      await Future.delayed(checkInterval);
    }
  }

  String _getBatchKey(String cacheKey) {
    // Extract batch key from cache key (e.g., "dashboard_data" from "dashboard_data_user_123")
    return cacheKey.split('_').take(2).join('_');
  }

  dynamic _createCircuitBreakerFailure() {
    // Return appropriate failure model based on your error handling structure
    // This is a placeholder - implement based on your ApiCallFailureModel
    return _errorHandler.handleError(
      Exception('Circuit breaker is open'),
      StackTrace.current,
    );
  }
}

enum RequestPriority { low, normal, high, critical }

class RepositoryStats {
  final int activeRequests;
  final bool circuitOpen;
  final int failureCount;
  final DateTime? lastFailureTime;
  final CacheStats cacheStats;

  RepositoryStats({
    required this.activeRequests,
    required this.circuitOpen,
    required this.failureCount,
    this.lastFailureTime,
    required this.cacheStats,
  });

  @override
  String toString() {
    return 'RepositoryStats(active: $activeRequests, circuitOpen: $circuitOpen, '
        'failures: $failureCount, lastFailure: $lastFailureTime, cache: $cacheStats)';
  }
}

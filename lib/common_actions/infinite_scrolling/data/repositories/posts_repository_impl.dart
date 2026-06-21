import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import 'package:flutter_specialized_temp/core/network/repository/scalable_base_repository.dart';
import 'package:flutter_specialized_temp/common_actions/infinite_scrolling/data/datasources/posts_remote_datasource.dart';
import 'package:flutter_specialized_temp/common_actions/infinite_scrolling/domain/entities/post.dart';
import 'package:flutter_specialized_temp/common_actions/infinite_scrolling/domain/repository/posts_repository.dart';
import 'package:injectable/injectable.dart';

/// High-performance posts repository implementation with advanced caching and optimization.
///
/// Features:
/// - Multi-layer caching with intelligent TTL
/// - Request deduplication and batching
/// - Circuit breaker for fault tolerance
/// - Background preloading
/// - Performance monitoring
/// - Memory efficient pagination
@Injectable(as: PostsRepository)
class PostsRepositoryImpl extends ScalableBaseRepository
    implements PostsRepository {
  PostsRepositoryImpl(
    super.errorHandler,
    super.cacheManager,
    this._remoteDataSource,
  );
  final PostsRemoteDataSource _remoteDataSource;

  // Performance tracking
  int _totalRequests = 0;
  final int _cacheHits = 0;
  final Map<String, DateTime> _lastFetchTimes = {};

  @override
  Future<ApiResult<List<Post>>> getPosts({
    int start = 0,
    int limit = 20,
    bool refresh = false,
  }) async {
    _totalRequests++;
    final pageKey = 'posts_page_${start ~/ limit}';

    AppLogger.d(
      message: '📝 Loading posts: start=$start, limit=$limit, refresh=$refresh',
    );

    return optimizedApiCall<List<Post>>(
      cacheKey: 'posts_entities_${start}_$limit',
      cacheTTL: _calculateCacheTTL(start),
      bypassCache: refresh,
      priority: start == 0 ? RequestPriority.high : RequestPriority.normal,
      apiCall: () async {
        final models = await _remoteDataSource.getPosts(
          start: start,
          limit: limit,
          bypassCache: refresh,
        );

        final entities = models.map((model) => model.toEntity()).toList();

        // Update fetch tracking
        _lastFetchTimes[pageKey] = DateTime.now();

        // Trigger background preloading for next page
        if (entities.length == limit && start < 100) {
          // Don't preload beyond 100 items
          _triggerBackgroundPreload(start + limit, limit);
        }

        AppLogger.i(
          message:
              '✅ Loaded ${entities.length} posts (page ${start ~/ limit + 1})',
        );

        return entities;
      },
    );
  }

  @override
  Future<ApiResult<void>> preloadCriticalPosts() async {
    AppLogger.i(message: '🚀 Preloading critical posts for app startup');

    return optimizedApiCall<void>(
      cacheKey: 'preload_critical_posts',
      cacheTTL: const Duration(minutes: 1), // Short TTL for preload tracking
      priority: RequestPriority.low,
      apiCall: () async {
        // Preload first page in background
        await getPosts();
        AppLogger.i(message: '✅ Critical posts preloaded successfully');
      },
    );
  }

  @override
  Future<ApiResult<List<Post>>> getPostsWithBackgroundRefresh({
    int start = 0,
    int limit = 20,
  }) async {
    final cacheKey = 'posts_entities_${start}_$limit';

    // First, try to get cached data immediately
    final cachedResult = await cacheManager.get<List<Post>>(cacheKey);

    if (cachedResult != null) {
      // Return cached data immediately
      final successResult = ApiSuccess(cachedResult);

      // Trigger background refresh if data is getting stale
      if (_isDataStale(start)) {
        _triggerBackgroundRefresh(start, limit);
      }

      return successResult;
    }

    // No cache available, fetch normally
    return getPosts(start: start, limit: limit);
  }

  @override
  Future<void> clearPostsCache() async {
    try {
      await _remoteDataSource.clearCache();
      await cacheManager.clearByPattern('posts_');
      _lastFetchTimes.clear();

      AppLogger.i(message: '🧹 Posts cache cleared completely');
    } catch (e) {
      AppLogger.e(message: '❌ Error clearing posts cache', error: e);
    }
  }

  @override
  Map<String, dynamic> getPerformanceMetrics() {
    final repositoryMetrics = {
      'total_requests': _totalRequests,
      'cache_hits': _cacheHits,
      'active_pages': _lastFetchTimes.length,
      'last_fetch_times': _lastFetchTimes.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };

    final dataSourceMetrics = _remoteDataSource.getPerformanceMetrics();
    final cacheStats = getPerformanceStats();

    return {
      'repository': repositoryMetrics,
      'data_source': dataSourceMetrics,
      'cache_stats': {
        'active_requests': cacheStats.activeRequests,
        'circuit_open': cacheStats.circuitOpen,
        'failure_count': cacheStats.failureCount,
        'cache_hit_rate': cacheStats.cacheStats.hitRate,
      },
    };
  }

  // Private helper methods

  Duration _calculateCacheTTL(int start) {
    // First page gets longer cache time (accessed more frequently)
    if (start == 0) {
      return const Duration(minutes: 15);
    }

    // Second page gets medium cache time
    if (start <= 20) {
      return const Duration(minutes: 10);
    }

    // Subsequent pages get shorter cache time
    return const Duration(minutes: 5);
  }

  bool _isDataStale(int start) {
    final pageKey = 'posts_page_${start ~/ 20}';
    final lastFetch = _lastFetchTimes[pageKey];

    if (lastFetch == null) return true;

    final staleDuration = start == 0
        ? const Duration(minutes: 5) // First page refreshes more frequently
        : const Duration(minutes: 10);

    return DateTime.now().difference(lastFetch) > staleDuration;
  }

  void _triggerBackgroundPreload(int start, int limit) {
    // Background preloading - fire and forget
    Future.delayed(const Duration(milliseconds: 500), () {
      getPosts(start: start, limit: limit).catchError((Object error) {
        AppLogger.w(message: '⚠️ Background preload failed: $error');
        return ApiFailure<List<Post>>(errorHandler.handleError(error));
      });
    });
  }

  void _triggerBackgroundRefresh(int start, int limit) {
    // Background refresh - fire and forget
    Future.delayed(const Duration(milliseconds: 100), () {
      getPosts(start: start, limit: limit, refresh: true).catchError((
        Object error,
      ) {
        AppLogger.w(message: '⚠️ Background refresh failed: $error');
        return ApiFailure<List<Post>>(errorHandler.handleError(error));
      });
    });
  }
}

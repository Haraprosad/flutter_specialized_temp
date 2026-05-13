import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/network/config/dio_client.dart';
import 'package:flutter_specialized_temp/core/network/enums/custom_error_type.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/custom_exception.dart';
import 'package:flutter_specialized_temp/core/network/cache/scalable_cache_manager.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/data/models/post_model.dart';
import 'package:injectable/injectable.dart';

/// Remote data source for posts with advanced caching and performance optimizations.
///
/// Features:
/// - Multi-layer caching for instant response
/// - Request deduplication to prevent redundant API calls
/// - Background preloading for smooth UX
/// - Memory-efficient pagination
/// - Circuit breaker protection
/// - Performance monitoring
abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts({
    int start = 0,
    int limit = 20,
    bool bypassCache = false,
  });

  Future<void> preloadNextPage(int currentPage);
  Future<void> clearCache();
  Map<String, dynamic> getPerformanceMetrics();
}

@Injectable(as: PostsRemoteDataSource)
class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final DioClient _dioClient;
  final ScalableCacheManager _cacheManager;

  // Performance optimizations for million users
  static const Duration _requestTimeout = Duration(seconds: 10);
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  // Performance tracking
  int _totalRequests = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;
  final Map<String, DateTime> _requestTimestamps = {};

  PostsRemoteDataSourceImpl(this._dioClient, this._cacheManager);

  @override
  Future<List<PostModel>> getPosts({
    int start = 0,
    int limit = 20,
    bool bypassCache = false,
  }) async {
    _totalRequests++;
    final cacheKey = 'posts_${start}_$limit';
    final requestId = '${cacheKey}_${DateTime.now().millisecondsSinceEpoch}';

    _requestTimestamps[requestId] = DateTime.now();

    try {
      // Try cache first unless bypassed
      if (!bypassCache) {
        final cached = await _cacheManager.get<List<PostModel>>(
          cacheKey,
          ttl: _cacheValidityDuration,
        );

        if (cached != null) {
          _cacheHits++;
          AppLogger.d(
            message: '🎯 Cache HIT for posts: start=$start, limit=$limit',
          );
          _logRequestPerformance(requestId, fromCache: true);
          return cached;
        }
      }

      _cacheMisses++;
      AppLogger.d(
        message: '🌐 API call for posts: start=$start, limit=$limit',
      );

      // API call with optimizations
      final response = await _dioClient.client.get(
        '/posts',
        queryParameters: {
          '_start': start,
          '_limit': limit,
        },
        options: Options(
          receiveTimeout: _requestTimeout,
          sendTimeout: _requestTimeout,
          extra: {
            'priority':
                start == 0 ? 'high' : 'normal', // First page gets priority
            'retry_count': 2,
          },
        ),
      );

      final posts = (response.data as List)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the result with optimized TTL
      final cacheTTL = _calculateOptimalCacheTTL(start, posts.length);
      await _cacheManager.put(cacheKey, posts, ttl: cacheTTL);

      AppLogger.i(
        message:
            '✅ Loaded ${posts.length} posts (start=$start) - cached for ${cacheTTL.inMinutes}min',
      );

      _logRequestPerformance(requestId, fromCache: false);

      return posts;
    } on DioException catch (e) {
      AppLogger.e(
        message: '❌ API error loading posts: ${e.message}',
        error: e,
      );

      // Try to return stale cache in case of network error
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        final staleCache = await _cacheManager.get<List<PostModel>>(
          cacheKey,
          ttl: Duration(days: 1), // Accept stale cache for network errors
        );

        if (staleCache != null) {
          AppLogger.w(
            message: '🔄 Returning stale cache due to network error',
          );
          return staleCache;
        }
      }

      rethrow;
    } catch (e) {
      AppLogger.e(
        message: '❌ Parsing error for posts data',
        error: e,
      );

      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    } finally {
      _requestTimestamps.remove(requestId);
    }
  }

  @override
  Future<void> preloadNextPage(int currentPage) async {
    try {
      final nextStart = (currentPage + 1) * 20;

      AppLogger.d(
        message: '🚀 Preloading next page: start=$nextStart',
      );

      // Background preloading - fire and forget
      getPosts(start: nextStart, limit: 20).catchError((error) {
        AppLogger.w(
          message: '⚠️ Preloading failed for page ${currentPage + 1}: $error',
        );
        return <PostModel>[]; // Return empty list for error case
      });
    } catch (e) {
      // Silent failure for preloading
      AppLogger.w(
        message: '⚠️ Preloading error: $e',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Clear posts-related cache entries
      await _cacheManager.clearByPattern('posts_');
      AppLogger.i(message: '🧹 Posts cache cleared');
    } catch (e) {
      AppLogger.e(
        message: '❌ Error clearing posts cache',
        error: e,
      );
    }
  }

  @override
  Map<String, dynamic> getPerformanceMetrics() {
    final cacheHitRate = _totalRequests > 0
        ? (_cacheHits / _totalRequests * 100).toStringAsFixed(1)
        : '0.0';

    return {
      'total_requests': _totalRequests,
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'cache_hit_rate': '$cacheHitRate%',
      'active_requests': _requestTimestamps.length,
      'last_request_time': _requestTimestamps.values.isNotEmpty
          ? _requestTimestamps.values.last.toIso8601String()
          : null,
    };
  }

  // Private helper methods

  Duration _calculateOptimalCacheTTL(int start, int itemCount) {
    // First page gets longer cache time as it's accessed more frequently
    if (start == 0) {
      return Duration(minutes: 10);
    }

    // Shorter cache for subsequent pages
    return Duration(minutes: 5);
  }

  void _logRequestPerformance(String requestId, {required bool fromCache}) {
    final startTime = _requestTimestamps[requestId];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      final source = fromCache ? 'CACHE' : 'API';

      AppLogger.d(
        message:
            '⏱️ Request completed in ${duration.inMilliseconds}ms ($source)',
      );

      // Log slow requests for monitoring
      if (!fromCache && duration.inSeconds > 2) {
        AppLogger.w(
          message: '🐌 Slow API request detected: ${duration.inSeconds}s',
        );
      }
    }
  }
}

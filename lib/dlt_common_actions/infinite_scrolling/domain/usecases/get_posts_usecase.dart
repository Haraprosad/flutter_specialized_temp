import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/entities/post.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/repository/posts_repository.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:injectable/injectable.dart';

/// Enhanced use case for posts with advanced features for million-user scalability.
///
/// Features:
/// - Smart caching strategies
/// - Background refresh capabilities
/// - Performance monitoring
/// - Preloading optimization
@injectable
class GetPostsUseCase {
  final PostsRepository _repository;

  GetPostsUseCase(this._repository);

  /// Gets posts with intelligent caching and performance optimization
  Future<ApiResult<List<Post>>> call({
    int start = 0,
    int limit = 20,
    bool refresh = false,
  }) {
    AppLogger.d(
      message:
          '🎯 Use case: Getting posts (start=$start, limit=$limit, refresh=$refresh)',
    );

    return _repository.getPosts(
      start: start,
      limit: limit,
      refresh: refresh,
    );
  }

  /// Gets posts with background refresh for optimal UX
  Future<ApiResult<List<Post>>> callWithBackgroundRefresh({
    int start = 0,
    int limit = 20,
  }) {
    AppLogger.d(
      message:
          '🔄 Use case: Getting posts with background refresh (start=$start)',
    );

    return _repository.getPostsWithBackgroundRefresh(
      start: start,
      limit: limit,
    );
  }
}

/// Use case for preloading critical posts during app initialization
@injectable
class PreloadPostsUseCase {
  final PostsRepository _repository;

  PreloadPostsUseCase(this._repository);

  Future<ApiResult<void>> call() {
    AppLogger.i(message: '🚀 Use case: Preloading critical posts');
    return _repository.preloadCriticalPosts();
  }
}

/// Use case for clearing posts cache when needed
@injectable
class ClearPostsCacheUseCase {
  final PostsRepository _repository;

  ClearPostsCacheUseCase(this._repository);

  Future<void> call() async {
    AppLogger.i(message: '🧹 Use case: Clearing posts cache');
    await _repository.clearPostsCache();
  }
}

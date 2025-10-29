// lib/features/posts/domain/repositories/posts_repository.dart
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/entities/post.dart';

abstract class PostsRepository {
  Future<ApiResult<List<Post>>> getPosts(
      {int start = 0, int limit = 20, bool refresh = false});
  Future<ApiResult<void>> preloadCriticalPosts();
  Future<ApiResult<List<Post>>> getPostsWithBackgroundRefresh(
      {int start = 0, int limit = 20});
  Future<void> clearPostsCache();
  Map<String, dynamic> getPerformanceMetrics();
}

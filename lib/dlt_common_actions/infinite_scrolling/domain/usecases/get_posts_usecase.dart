import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/entities/post.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/repository/posts_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPostsUseCase {
  final PostsRepository _repository;

  GetPostsUseCase(this._repository);

  Future<ApiResult<List<Post>>> call({int start = 0, int limit = 10}) {
    return _repository.getPosts(start: start, limit: limit);
  }
}
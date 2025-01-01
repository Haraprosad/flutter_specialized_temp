import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/network/config/dio_client.dart';
import 'package:flutter_specialized_temp/core/network/enums/custom_error_type.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/custom_exception.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/data/models/post_model.dart';
import 'package:injectable/injectable.dart';


abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts({int start = 0, int limit = 0});
}

@Injectable(as: PostsRemoteDataSource)
class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final DioClient _dioClient;
  PostsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PostModel>> getPosts({int start = 0, int limit = 0}) async {
    try {
      final response = await _dioClient.client.get('/posts', queryParameters: {
        '_start': start,
        '_limit': limit,
      });

      return (response.data as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } on DioException {
      rethrow;
    } catch (e) {
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }
}

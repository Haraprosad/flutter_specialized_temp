import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/utils/throttle_droppable.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_state.dart';
import 'package:flutter_specialized_temp/core/network/bloc/base_bloc.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/usecases/get_posts_usecase.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_event.dart';
import 'package:injectable/injectable.dart';

@injectable
class PostsBloc extends BaseBloc<PostsEvent, PostsState> {
  final GetPostsUseCase _getPostsUseCase;
  static const int _postLimit = 20;

  PostsBloc(this._getPostsUseCase) : super(const PostsState()) {
    on<PostsFetched>(_onFetchPosts);
    on<PostsLoadMore>(_onLoadMorePosts, transformer: throttleDroppable(throttleDuration));
  }

  Future<void> _onFetchPosts(
    PostsFetched event,
    Emitter<PostsState> emit,
  ) async {
    await handleApiCall(
      apiCall: () => _getPostsUseCase(start: 0, limit: _postLimit),
      onSuccess: (posts) {
        emit(state.copyWith(
          posts: posts,
          hasReachedMax: posts.length < _postLimit,
        ));
      },
      emit: emit,
    );
  }

  Future<void> _onLoadMorePosts(
    PostsLoadMore event,
    Emitter<PostsState> emit,
  ) async {
    if (state.hasReachedMax) return;

    emit(state.copyWith(isPaginationLoading: true));

    await handleApiCall(
      apiCall: () => _getPostsUseCase(
        start: state.posts.length,
        limit: _postLimit,
      ),
      onSuccess: (posts) {
        emit(state.copyWith(
          posts: [...state.posts, ...posts],
          hasReachedMax: posts.length < _postLimit,
          isPaginationLoading: false,
        ));
      },
      onError: (failure) {
        emit(state.copyWith(hasReachedMax: true, failure: failure,isPaginationLoading: false));
      },
      emit: emit,
      showLoader: false,
    );
  }
}
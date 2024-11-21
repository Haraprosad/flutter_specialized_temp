import 'package:equatable/equatable.dart';
import 'package:flutter_specialized_temp/core/network/bloc/base_bloc_state.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/entities/post.dart';

final class PostsState extends Equatable implements BaseBlocState {
  /// List of posts retrieved
  final List<Post> posts;

  /// Indicates if all posts have been loaded
  final bool hasReachedMax;

  /// Indicates if an API request is currently in progress
  @override
  final bool isLoading;

  /// Indicates if pagination loading is in progress
  final bool isPaginationLoading;

  /// Contains any error details related to network requests
  @override
  final ApiCallFailureModel? failure;

  /// Constructor with default values and optional parameters
  const PostsState({
    this.posts = const <Post>[],
    this.hasReachedMax = false,
    this.isLoading = false,
    this.isPaginationLoading = false,
    this.failure,
  });

  /// Creates a copy of the current state with optional parameter overrides
  @override
  PostsState copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
    bool? isLoading,
    bool? isPaginationLoading,
    ApiCallFailureModel? failure,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      failure: failure ?? this.failure,
    );
  }

  /// Implements Equatable to allow state comparison
  @override
  List<Object?> get props => [posts, hasReachedMax, isLoading, isPaginationLoading, failure];

  /// Provides a string representation of the state
  @override
  String toString() {
    return 'PostState { '
        'posts: ${posts.length}, '
        'hasReachedMax: $hasReachedMax, '
        'isLoading: $isLoading, '
        'isPaginationLoading: $isPaginationLoading, '
        'failure: $failure '
        '}';
  }
}
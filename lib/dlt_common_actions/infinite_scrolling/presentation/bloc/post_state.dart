import 'package:equatable/equatable.dart';
import 'package:flutter_specialized_temp/core/network/bloc/base_bloc_state.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/entities/post.dart';

/// Performance metrics for monitoring and optimization
class PerformanceMetrics extends Equatable {
  const PerformanceMetrics({
    required this.loadTime,
    required this.itemCount,
    required this.timestamp,
    this.fromCache = false,
    this.scrollPosition,
  });
  final int loadTime; // milliseconds
  final int itemCount;
  final DateTime timestamp;
  final bool fromCache;
  final double? scrollPosition;

  @override
  List<Object?> get props => [
    loadTime,
    itemCount,
    timestamp,
    fromCache,
    scrollPosition,
  ];
}

final class PostsState extends Equatable implements BaseBlocState {
  /// Constructor with default values and optional parameters
  const PostsState({
    this.posts = const <Post>[],
    this.hasReachedMax = false,
    this.isLoading = false,
    this.isPaginationLoading = false,
    this.isBackgroundRefreshing = false,
    this.failure,
    this.lastFetchTime,
    this.performanceMetrics,
    this.currentPage = 0,
    this.isFromCache = false,
  });

  /// List of posts retrieved
  final List<Post> posts;

  /// Indicates if all posts have been loaded
  final bool hasReachedMax;

  /// Indicates if an API request is currently in progress
  @override
  final bool isLoading;

  /// Indicates if pagination loading is in progress
  final bool isPaginationLoading;

  /// Indicates if background refresh is in progress
  final bool isBackgroundRefreshing;

  /// Contains any error details related to network requests
  @override
  final ApiCallFailureModel? failure;

  /// Timestamp of last successful fetch
  final DateTime? lastFetchTime;

  /// Performance metrics for monitoring
  final PerformanceMetrics? performanceMetrics;

  /// Current page number (for tracking)
  final int currentPage;

  /// Indicates if data is from cache
  final bool isFromCache;

  /// Creates a copy of the current state with optional parameter overrides
  @override
  PostsState copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
    bool? isLoading,
    bool? isPaginationLoading,
    bool? isBackgroundRefreshing,
    ApiCallFailureModel? failure,
    DateTime? lastFetchTime,
    PerformanceMetrics? performanceMetrics,
    int? currentPage,
    bool? isFromCache,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      isBackgroundRefreshing:
          isBackgroundRefreshing ?? this.isBackgroundRefreshing,
      failure: failure,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      currentPage: currentPage ?? this.currentPage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  /// Convenience getters for common state checks
  bool get hasData => posts.isNotEmpty;
  bool get hasError => failure != null;
  bool get isInitialLoading => isLoading && posts.isEmpty;
  bool get canLoadMore => !hasReachedMax && !isPaginationLoading && !isLoading;

  /// Check if data is fresh (less than 5 minutes old)
  bool get isDataFresh {
    if (lastFetchTime == null) return false;
    return DateTime.now().difference(lastFetchTime!) <
        const Duration(minutes: 5);
  }

  /// Implements Equatable to allow state comparison
  @override
  List<Object?> get props => [
    posts,
    hasReachedMax,
    isLoading,
    isPaginationLoading,
    isBackgroundRefreshing,
    failure,
    lastFetchTime,
    performanceMetrics,
    currentPage,
    isFromCache,
  ];

  /// Provides a string representation of the state
  @override
  String toString() {
    return 'PostsState { '
        'posts: ${posts.length}, '
        'hasReachedMax: $hasReachedMax, '
        'isLoading: $isLoading, '
        'isPaginationLoading: $isPaginationLoading, '
        'isBackgroundRefreshing: $isBackgroundRefreshing, '
        'currentPage: $currentPage, '
        'isFromCache: $isFromCache, '
        'failure: $failure '
        '}';
  }
}

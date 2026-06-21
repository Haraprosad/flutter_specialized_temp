import 'package:equatable/equatable.dart';

sealed class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

/// Initial load of posts with smart caching
final class PostsFetched extends PostsEvent {
  const PostsFetched();
}

/// Load more posts for infinite scrolling
final class PostsLoadMore extends PostsEvent {
  const PostsLoadMore();
}

/// Refresh posts (pull-to-refresh)
final class PostsRefresh extends PostsEvent {
  const PostsRefresh();
}

/// Preload next page in background for smooth UX
final class PostsPreloadNext extends PostsEvent {
  const PostsPreloadNext();
}

/// Clear all posts cache
final class PostsClearCache extends PostsEvent {
  const PostsClearCache();
}

/// Load posts with background refresh (returns cached immediately, refreshes in background)
final class PostsLoadWithBackgroundRefresh extends PostsEvent {
  const PostsLoadWithBackgroundRefresh();
}

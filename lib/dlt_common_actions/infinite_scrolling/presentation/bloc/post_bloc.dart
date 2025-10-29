import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/network/utils/debounce_utils.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_state.dart';
import 'package:flutter_specialized_temp/core/network/bloc/base_bloc.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/usecases/get_posts_usecase.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_event.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:injectable/injectable.dart';

/// High-performance PostsBloc optimized for million-user scalability.
///
/// Features:
/// - Intelligent event debouncing and deduplication
/// - Background data refresh for smooth UX
/// - Performance monitoring and metrics
/// - Smart caching with cache-first strategy
/// - Memory-efficient state management
/// - Automatic preloading for smooth scrolling
@injectable
class PostsBloc extends BaseBloc<PostsEvent, PostsState> {
  final GetPostsUseCase _getPostsUseCase;
  final PreloadPostsUseCase _preloadPostsUseCase;
  final ClearPostsCacheUseCase _clearPostsCacheUseCase;

  // Optimized configuration for million users
  static const int _postsPerPage = 20;
  static const Duration _debounceTime = Duration(milliseconds: 300);
  static const Duration _backgroundRefreshInterval = Duration(minutes: 5);

  // Performance tracking
  final Stopwatch _performanceTimer = Stopwatch();
  Timer? _backgroundRefreshTimer;
  final Set<String> _processedEvents = {};

  PostsBloc(
    this._getPostsUseCase,
    this._preloadPostsUseCase,
    this._clearPostsCacheUseCase,
  ) : super(const PostsState()) {
    // Register event handlers with optimizations
    on<PostsFetched>(_onFetchPosts);
    on<PostsLoadMore>(
      _onLoadMorePosts,
      transformer: throttleDroppable(_debounceTime),
    );
    on<PostsRefresh>(_onRefreshPosts);
    on<PostsPreloadNext>(_onPreloadNext);
    on<PostsClearCache>(_onClearCache);
    on<PostsLoadWithBackgroundRefresh>(_onLoadWithBackgroundRefresh);

    // Setup background refresh timer
    _setupBackgroundRefresh();
  }

  Future<void> _onFetchPosts(
    PostsFetched event,
    Emitter<PostsState> emit,
  ) async {
    final eventId = 'fetch_${DateTime.now().millisecondsSinceEpoch}';

    // Prevent duplicate events
    if (_isDuplicateEvent(eventId)) {
      AppLogger.d(message: '🚫 Duplicate fetch event ignored');
      return;
    }

    _performanceTimer.reset();
    _performanceTimer.start();

    AppLogger.i(message: '📱 Fetching initial posts');

    await handleApiCall(
      apiCall: () => _getPostsUseCase(start: 0, limit: _postsPerPage),
      onSuccess: (posts) {
        _performanceTimer.stop();

        final metrics = PerformanceMetrics(
          loadTime: _performanceTimer.elapsedMilliseconds,
          itemCount: posts.length,
          timestamp: DateTime.now(),
          fromCache: false, // First load typically from API
        );

        emit(state.copyWith(
          posts: posts,
          hasReachedMax: posts.length < _postsPerPage,
          lastFetchTime: DateTime.now(),
          performanceMetrics: metrics,
          currentPage: 0,
          failure: null,
        ));

        AppLogger.i(
          message:
              '✅ Loaded ${posts.length} posts in ${_performanceTimer.elapsedMilliseconds}ms',
        );

        // Trigger background preloading if we have data
        if (posts.isNotEmpty && !state.hasReachedMax) {
          add(const PostsPreloadNext());
        }
      },
      emit: emit,
      showLoader: true,
    );

    _markEventProcessed(eventId);
  }

  Future<void> _onLoadMorePosts(
    PostsLoadMore event,
    Emitter<PostsState> emit,
  ) async {
    if (!state.canLoadMore) {
      AppLogger.d(message: '🚫 Cannot load more posts');
      return;
    }

    final nextPage = state.currentPage + 1;
    final start = state.posts.length;

    AppLogger.d(message: '📄 Loading more posts (page $nextPage)');

    emit(state.copyWith(isPaginationLoading: true));

    await handleApiCall(
      apiCall: () => _getPostsUseCase(
        start: start,
        limit: _postsPerPage,
      ),
      onSuccess: (newPosts) {
        final allPosts = [...state.posts, ...newPosts];

        emit(state.copyWith(
          posts: allPosts,
          hasReachedMax: newPosts.length < _postsPerPage,
          isPaginationLoading: false,
          currentPage: nextPage,
          lastFetchTime: DateTime.now(),
          failure: null,
        ));

        AppLogger.i(
            message:
                '✅ Loaded ${newPosts.length} more posts (total: ${allPosts.length})');

        // Trigger preloading when user is approaching end
        if (newPosts.isNotEmpty && !state.hasReachedMax) {
          add(const PostsPreloadNext());
        }
      },
      onError: (failure) {
        emit(state.copyWith(
          isPaginationLoading: false,
          failure: failure,
        ));
      },
      emit: emit,
      showLoader: false,
    );
  }

  Future<void> _onRefreshPosts(
    PostsRefresh event,
    Emitter<PostsState> emit,
  ) async {
    AppLogger.i(message: '🔄 Refreshing posts');

    _performanceTimer.reset();
    _performanceTimer.start();

    await handleApiCall(
      apiCall: () =>
          _getPostsUseCase(start: 0, limit: _postsPerPage, refresh: true),
      onSuccess: (posts) {
        _performanceTimer.stop();

        final metrics = PerformanceMetrics(
          loadTime: _performanceTimer.elapsedMilliseconds,
          itemCount: posts.length,
          timestamp: DateTime.now(),
          fromCache: false,
        );

        emit(state.copyWith(
          posts: posts,
          hasReachedMax: posts.length < _postsPerPage,
          lastFetchTime: DateTime.now(),
          performanceMetrics: metrics,
          currentPage: 0,
          failure: null,
        ));

        AppLogger.i(message: '✅ Refreshed ${posts.length} posts');
      },
      emit: emit,
      showLoader: state.posts.isEmpty, // Only show loader if no existing data
    );
  }

  Future<void> _onPreloadNext(
    PostsPreloadNext event,
    Emitter<PostsState> emit,
  ) async {
    if (state.hasReachedMax) return;

    // Background preloading - don't show loading states
    try {
      AppLogger.d(message: '🚀 Preloading critical posts');

      await _preloadPostsUseCase();

      AppLogger.d(message: '✅ Preload completed');
    } catch (e) {
      // Silent failure for preloading
      AppLogger.w(message: '⚠️ Preloading failed: $e');
    }
  }

  Future<void> _onClearCache(
    PostsClearCache event,
    Emitter<PostsState> emit,
  ) async {
    try {
      await _clearPostsCacheUseCase();

      // Reset state to initial
      emit(const PostsState());

      AppLogger.i(message: '🧹 Posts cache cleared, state reset');
    } catch (e) {
      AppLogger.e(message: '❌ Error clearing cache: $e');
    }
  }

  Future<void> _onLoadWithBackgroundRefresh(
    PostsLoadWithBackgroundRefresh event,
    Emitter<PostsState> emit,
  ) async {
    AppLogger.d(message: '🔄 Loading with background refresh');

    await handleApiCall(
      apiCall: () => _getPostsUseCase.callWithBackgroundRefresh(
          start: 0, limit: _postsPerPage),
      onSuccess: (posts) {
        emit(state.copyWith(
          posts: posts,
          hasReachedMax: posts.length < _postsPerPage,
          lastFetchTime: DateTime.now(),
          currentPage: 0,
          isFromCache: true, // Likely from cache for background refresh
          failure: null,
        ));

        AppLogger.i(
            message: '✅ Loaded ${posts.length} posts with background refresh');
      },
      emit: emit,
      showLoader: state.posts.isEmpty,
    );
  }

  // Private helper methods

  void _setupBackgroundRefresh() {
    _backgroundRefreshTimer =
        Timer.periodic(_backgroundRefreshInterval, (timer) {
      if (state.hasData && !isClosed) {
        AppLogger.d(message: '⏰ Background refresh triggered');
        add(const PostsLoadWithBackgroundRefresh());
      }
    });
  }

  bool _isDuplicateEvent(String eventId) {
    if (_processedEvents.contains(eventId)) {
      return true;
    }

    // Clean old events (keep only last 10)
    if (_processedEvents.length > 10) {
      final eventsToRemove =
          _processedEvents.take(_processedEvents.length - 10);
      _processedEvents.removeAll(eventsToRemove);
    }

    return false;
  }

  void _markEventProcessed(String eventId) {
    _processedEvents.add(eventId);
  }

  @override
  Future<void> close() {
    _backgroundRefreshTimer?.cancel();
    _performanceTimer.stop();
    _processedEvents.clear();
    return super.close();
  }
}

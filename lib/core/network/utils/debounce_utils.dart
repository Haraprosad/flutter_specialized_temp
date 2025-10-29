import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

/// 🎯 Centralized debouncing utilities for network operations
///
/// **Use Cases:**
/// - Search input (debounce API calls while user types)
/// - Autocomplete suggestions
/// - Form validation with API checks
/// - Any rapid user input that triggers network calls
///
/// **Why Debounce?**
/// - Reduces API calls (user types "hello" = 1 API call instead of 5)
/// - Saves bandwidth and server load
/// - Better user experience (no flickering results)
/// - Million-user scalability (prevents self-DDoS)
///
/// **Example:**
/// ```dart
/// final searchDebouncer = Debouncer(delay: Duration(milliseconds: 500));
///
/// void onSearchChanged(String query) {
///   searchDebouncer.run(() {
///     // This only runs 500ms after user stops typing
///     context.read<SearchBloc>().add(SearchQuery(query));
///   });
/// }
/// ```

/// Debouncer - Delays execution until user stops performing action
///
/// **Best for:** Search, autocomplete, rapid input
/// **Pattern:** Wait for user to finish, then execute ONCE
///
/// Example: User types "hello"
/// - h → waits 500ms
/// - he → cancels previous, waits 500ms
/// - hel → cancels previous, waits 500ms
/// - hell → cancels previous, waits 500ms
/// - hello → cancels previous, waits 500ms → ✅ EXECUTES (only once!)
class Debouncer {
  /// Delay duration before executing callback
  final Duration delay;

  Timer? _timer;

  /// Create debouncer with specified delay
  ///
  /// **Recommended delays:**
  /// - Search: 300-500ms (responsive but not spammy)
  /// - Autocomplete: 250-400ms (fast suggestions)
  /// - Form validation: 500-800ms (wait for user to finish)
  /// - Heavy operations: 800-1000ms (save resources)
  Debouncer({required this.delay});

  /// Run callback after delay (cancels previous pending calls)
  ///
  /// Example:
  /// ```dart
  /// final debouncer = Debouncer(delay: Duration(milliseconds: 500));
  ///
  /// TextField(
  ///   onChanged: (value) {
  ///     debouncer.run(() {
  ///       // Only runs 500ms after user stops typing
  ///       searchProducts(value);
  ///     });
  ///   },
  /// )
  /// ```
  void run(VoidCallback action) {
    // Cancel previous timer if it exists
    _timer?.cancel();

    // Start new timer
    _timer = Timer(delay, action);
  }

  /// Cancel pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if debouncer has pending execution
  bool get isActive => _timer?.isActive ?? false;

  /// Dispose and clean up resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler - Executes at most once per time period
///
/// **Best for:** Button clicks, scroll events, rapid API refresh
/// **Pattern:** Execute immediately, then BLOCK for duration
///
/// Example: User clicks button 5 times in 1 second
/// - Click 1 → ✅ EXECUTES immediately
/// - Click 2 → ❌ Blocked (within 1 second)
/// - Click 3 → ❌ Blocked (within 1 second)
/// - Click 4 → ❌ Blocked (within 1 second)
/// - Click 5 → ❌ Blocked (within 1 second)
/// - Wait 1 second...
/// - Click 6 → ✅ EXECUTES (cooldown finished)
class Throttler {
  /// Minimum duration between executions
  final Duration duration;

  DateTime? _lastExecutionTime;

  /// Create throttler with specified duration
  ///
  /// **Recommended durations:**
  /// - Button clicks: 500-1000ms (prevent double-tap)
  /// - Scroll events: 100-200ms (smooth but responsive)
  /// - API refresh: 800-1500ms (prevent spam)
  /// - Like/favorite actions: 300-500ms (instant feel)
  Throttler({required this.duration});

  /// Execute callback if cooldown period has passed
  ///
  /// Returns true if callback was executed, false if throttled
  ///
  /// Example:
  /// ```dart
  /// final throttler = Throttler(duration: Duration(seconds: 1));
  ///
  /// ElevatedButton(
  ///   onPressed: () {
  ///     throttler.run(() {
  ///       // Only runs once per second, even if button spammed
  ///       likePost();
  ///     });
  ///   },
  /// )
  /// ```
  bool run(VoidCallback action) {
    final now = DateTime.now();

    // First execution or cooldown period has passed
    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= duration) {
      _lastExecutionTime = now;
      action();
      return true;
    }

    // Still in cooldown period - throttled
    return false;
  }

  /// Reset throttler (next call will execute immediately)
  void reset() {
    _lastExecutionTime = null;
  }

  /// Check if throttler is in cooldown period
  bool get isInCooldown {
    if (_lastExecutionTime == null) return false;

    final now = DateTime.now();
    return now.difference(_lastExecutionTime!) < duration;
  }

  /// Get remaining cooldown time (null if not in cooldown)
  Duration? get remainingCooldown {
    if (_lastExecutionTime == null) return null;

    final now = DateTime.now();
    final elapsed = now.difference(_lastExecutionTime!);

    if (elapsed >= duration) return null;

    return duration - elapsed;
  }
}

/// AsyncDebouncer - Debouncer for async operations with cancellation support
///
/// **Best for:** API calls, database queries, async form validation
/// **Pattern:** Wait for user to finish, then execute ONCE (with cancellation)
///
/// **Key Features:**
/// - Automatically cancels previous pending async operations
/// - Returns result of last execution
/// - Handles errors gracefully
///
/// Example:
/// ```dart
/// final apiDebouncer = AsyncDebouncer<List<Product>>(
///   delay: Duration(milliseconds: 500),
/// );
///
/// void searchProducts(String query) async {
///   final products = await apiDebouncer.run(() async {
///     return await api.searchProducts(query);
///   });
///
///   if (products != null) {
///     // Only runs for last search query
///     updateUI(products);
///   }
/// }
/// ```
class AsyncDebouncer<T> {
  /// Delay duration before executing callback
  final Duration delay;

  Timer? _timer;
  Completer<T?>? _completer;

  /// Create async debouncer with specified delay
  AsyncDebouncer({required this.delay});

  /// Run async callback after delay (cancels previous pending calls)
  ///
  /// Returns result of callback or null if cancelled
  Future<T?> run(Future<T> Function() action) async {
    // Cancel previous timer and complete with null
    _timer?.cancel();
    _completer?.complete(null);

    // Create new completer for this execution
    _completer = Completer<T?>();

    // Start new timer
    _timer = Timer(delay, () async {
      try {
        final result = await action();
        if (!_completer!.isCompleted) {
          _completer!.complete(result);
        }
      } catch (e) {
        if (!_completer!.isCompleted) {
          _completer!.completeError(e);
        }
      }
    });

    return _completer!.future;
  }

  /// Cancel pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }
  }

  /// Dispose and clean up resources
  void dispose() {
    cancel();
  }
}

/// 🎯 Pre-configured debouncers for common use cases
class NetworkDebouncers {
  /// Search input debouncer (500ms)
  /// Use for: Search bars, product search, user search
  static final search = Debouncer(delay: const Duration(milliseconds: 500));

  /// Autocomplete debouncer (300ms)
  /// Use for: Autocomplete dropdowns, location search, tag suggestions
  static final autocomplete =
      Debouncer(delay: const Duration(milliseconds: 300));

  /// Form validation debouncer (800ms)
  /// Use for: Email validation, username check, phone validation
  static final formValidation =
      Debouncer(delay: const Duration(milliseconds: 800));

  /// API refresh throttler (1000ms)
  /// Use for: Pull-to-refresh, retry button, reload actions
  static final apiRefresh =
      Throttler(duration: const Duration(milliseconds: 1000));

  /// Button click throttler (500ms)
  /// Use for: Submit buttons, like buttons, favorite actions
  static final buttonClick =
      Throttler(duration: const Duration(milliseconds: 500));

  /// Async search debouncer (500ms)
  /// Use for: API search calls with cancellation
  static AsyncDebouncer<dynamic> createAsyncSearch() =>
      AsyncDebouncer(delay: const Duration(milliseconds: 500));
}

/// 📊 Performance tracking for debouncing
class DebounceMetrics {
  int _totalCalls = 0;
  int _executedCalls = 0;
  int _throttledCalls = 0;

  /// Record a call attempt
  void recordCall() {
    _totalCalls++;
  }

  /// Record an executed call
  void recordExecution() {
    _executedCalls++;
  }

  /// Record a throttled/cancelled call
  void recordThrottled() {
    _throttledCalls++;
  }

  /// Get total number of calls
  int get totalCalls => _totalCalls;

  /// Get number of executed calls
  int get executedCalls => _executedCalls;

  /// Get number of throttled calls
  int get throttledCalls => _throttledCalls;

  /// Get percentage of calls that were prevented
  double get savingsPercentage {
    if (_totalCalls == 0) return 0.0;
    return ((_totalCalls - _executedCalls) / _totalCalls) * 100;
  }

  /// Reset metrics
  void reset() {
    _totalCalls = 0;
    _executedCalls = 0;
    _throttledCalls = 0;
  }

  @override
  String toString() {
    return 'DebounceMetrics(total: $_totalCalls, executed: $_executedCalls, '
        'saved: $_throttledCalls, savings: ${savingsPercentage.toStringAsFixed(1)}%)';
  }
}

/// 🎯 Tracked Debouncer with performance metrics
class TrackedDebouncer extends Debouncer {
  final DebounceMetrics metrics = DebounceMetrics();

  TrackedDebouncer({required super.delay});

  @override
  void run(VoidCallback action) {
    metrics.recordCall();

    super.run(() {
      metrics.recordExecution();
      action();
    });
  }

  @override
  void cancel() {
    if (isActive) {
      metrics.recordThrottled();
    }
    super.cancel();
  }
}

/// 🎯 Tracked Throttler with performance metrics
class TrackedThrottler extends Throttler {
  final DebounceMetrics metrics = DebounceMetrics();

  TrackedThrottler({required super.duration});

  @override
  bool run(VoidCallback action) {
    metrics.recordCall();

    final executed = super.run(action);

    if (executed) {
      metrics.recordExecution();
    } else {
      metrics.recordThrottled();
    }

    return executed;
  }
}

// ============================================================================
// 🎯 BLoC Event Transformers (for event streams)
// ============================================================================

/// Event transformer to prevent multiple concurrent requests with throttling
///
/// **Best for:** Infinite scroll, load more, pagination events
/// **Pattern:** Throttle events + Drop concurrent requests
///
/// **Example:**
/// ```dart
/// class PostsBloc extends Bloc<PostsEvent, PostsState> {
///   PostsBloc() : super(PostsInitial()) {
///     on<LoadMorePosts>(
///       _onLoadMore,
///       transformer: throttleDroppable(Duration(milliseconds: 300)),
///     );
///   }
/// }
/// ```
///
/// **Benefits:**
/// - ✅ Prevents API spam (throttles rapid events)
/// - ✅ Drops concurrent requests (prevents race conditions)
/// - ✅ Million-user safe (handles high load)
/// - ✅ Perfect for scroll/pagination (smooth UX)
EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

/// Event transformer with debouncing (wait for user to stop)
///
/// **Best for:** Search events, text input events
/// **Pattern:** Wait for pause, then execute
///
/// **Example:**
/// ```dart
/// class SearchBloc extends Bloc<SearchEvent, SearchState> {
///   SearchBloc() : super(SearchInitial()) {
///     on<SearchQueryChanged>(
///       _onSearch,
///       transformer: debounceDroppable(Duration(milliseconds: 500)),
///     );
///   }
/// }
/// ```
EventTransformer<E> debounceDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.debounce(duration), mapper);
  };
}

import 'dart:async';
import 'dart:collection';

import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:injectable/injectable.dart';

/// Freshness of a cached entry at lookup time.
///
/// - [fresh] — within the stale window; serve directly, no network needed.
/// - [stale] — past the stale window but still within max age; serve
///   immediately AND revalidate in the background (stale-while-revalidate).
/// - [miss]  — absent or past max age; the caller must fetch and wait.
enum CacheFreshness { fresh, stale, miss }

/// Result of a non-evicting cache lookup. [value] is only meaningful when
/// [freshness] is [CacheFreshness.fresh] or [CacheFreshness.stale].
class CacheLookup<T> {
  const CacheLookup(this.value, this.freshness);
  final T? value;
  final CacheFreshness freshness;

  bool get isFresh => freshness == CacheFreshness.fresh;
  bool get isStale => freshness == CacheFreshness.stale;
  bool get isMiss => freshness == CacheFreshness.miss;

  /// True when there is a usable value to serve (fresh or stale).
  bool get hasValue => value != null && freshness != CacheFreshness.miss;
}

/// Enhanced in-memory cache manager with stale-while-revalidate (SWR) support.
///
/// Features:
/// - Memory cache (L1) for instant access
/// - Two-phase lifetime per entry: a *stale window* and a hard *max age*
/// - Stale-while-revalidate: serve cached data instantly past the stale
///   window while a background refresh fetches fresh data
/// - LRU eviction for memory management
/// - Cache warming and preloading
/// - Memory pressure handling
/// - Statistics and monitoring
/// - Concurrent request deduplication
///
/// NOTE: This cache is in-memory only — entries do not survive an app
/// restart. Cross-restart (true offline) persistence is intentionally not
/// implemented here; use Drift or the mutation queue for durable storage.
@lazySingleton
class ScalableCacheManager {
  ScalableCacheManager() {
    _startMemoryPressureMonitoring();
  }
  // Memory cache with LRU eviction
  final LinkedHashMap<String, _CacheEntry> _memoryCache = LinkedHashMap();
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  // Configuration
  static const int _maxMemoryCacheSize =
      100; // Configurable based on device capacity
  static const Duration _defaultStaleAfter = Duration(minutes: 5);
  static const Duration _defaultMaxAge = Duration(hours: 1);
  static const Duration _memoryPressureCheckInterval = Duration(minutes: 1);

  // Statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _staleHitCount = 0;
  int _evictionCount = 0;

  Timer? _memoryPressureTimer;

  /// Non-evicting lookup that reports the freshness of an entry without
  /// fetching. This is the primary entry point for stale-while-revalidate:
  /// callers serve [CacheLookup.value] immediately and decide whether to
  /// revalidate based on [CacheLookup.freshness].
  CacheLookup<T> peek<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) {
      _missCount++;
      return CacheLookup<T>(null, CacheFreshness.miss);
    }

    final now = DateTime.now();

    // Past hard max age — drop it and report a miss.
    if (now.isAfter(entry.expiresAt)) {
      _memoryCache.remove(key);
      _missCount++;
      AppLogger.d(message: '❌ Cache MISS (expired): $key');
      return CacheLookup<T>(null, CacheFreshness.miss);
    }

    // Still usable — refresh LRU position.
    _memoryCache
      ..remove(key)
      ..[key] = entry;

    if (now.isBefore(entry.staleAt)) {
      _hitCount++;
      AppLogger.d(message: '🎯 Cache HIT (fresh): $key');
      return CacheLookup<T>(entry.data as T?, CacheFreshness.fresh);
    }

    _staleHitCount++;
    AppLogger.d(message: '🕰️ Cache HIT (stale, will revalidate): $key');
    return CacheLookup<T>(entry.data as T?, CacheFreshness.stale);
  }

  /// Gets data from cache with automatic fallback chain:
  /// Memory -> fallbackLoader -> cache update.
  ///
  /// Returns any non-expired value (fresh or stale). For freshness-aware
  /// behaviour prefer [peek].
  Future<T?> get<T>(
    String key, {
    Duration? ttl,
    Duration? staleAfter,
    Duration? maxAge,
    Future<T> Function()? fallbackLoader,
  }) async {
    // Try memory cache first (L1) — accept stale, only expired counts as miss.
    final lookup = peek<T>(key);
    if (lookup.hasValue) {
      return lookup.value;
    }

    // Deduplicate concurrent requests for same key
    if (_pendingRequests.containsKey(key)) {
      AppLogger.d(message: '⏳ Deduplicating request for: $key');
      return await _pendingRequests[key]!.future as T?;
    }

    // Create completer for deduplication
    final completer = Completer<T?>();
    _pendingRequests[key] = completer as Completer<dynamic>;

    try {
      T? result;

      // Try fallback loader if provided
      if (fallbackLoader != null) {
        result = await fallbackLoader();
        if (result != null) {
          await put(
            key,
            result,
            ttl: ttl,
            staleAfter: staleAfter,
            maxAge: maxAge,
          );
        }
      }

      completer.complete(result);
      return result;
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _pendingRequests.remove(key);
    }
  }

  /// Stores data in the memory cache.
  ///
  /// [staleAfter] sets how long the value is considered fresh; once past it
  /// the value is served stale while a background refresh runs. [maxAge]
  /// caps how long the value may be served at all. [ttl] is a backward-compat
  /// alias that, when provided, seeds [staleAfter].
  Future<void> put<T>(
    String key,
    T data, {
    Duration? ttl,
    Duration? staleAfter,
    Duration? maxAge,
  }) async {
    final effectiveStale = staleAfter ?? ttl ?? _defaultStaleAfter;
    var effectiveMax = maxAge ?? _defaultMaxAge;
    if (effectiveMax < effectiveStale) {
      // Max age must cover at least the stale window.
      effectiveMax = effectiveStale;
    }

    final now = DateTime.now();
    _putInMemory(
      key,
      data,
      staleAt: now.add(effectiveStale),
      expiresAt: now.add(effectiveMax),
    );

    AppLogger.d(
      message:
          '💾 Cached: $key (stale after ${effectiveStale.inMinutes}min, '
          'expires ${effectiveMax.inMinutes}min)',
    );
  }

  /// Preloads critical data into cache during idle time
  Future<void> warmup<T>(
    Map<String, Future<T> Function()> loaders, {
    Duration? ttl,
    Duration? staleAfter,
    Duration? maxAge,
  }) async {
    AppLogger.i(
      message: '🔥 Starting cache warmup for ${loaders.length} items',
    );

    final futures = loaders.entries.map((entry) async {
      try {
        final data = await entry.value();
        await put(
          entry.key,
          data,
          ttl: ttl,
          staleAfter: staleAfter,
          maxAge: maxAge,
        );
        AppLogger.d(message: '✅ Warmed up: ${entry.key}');
      } catch (error) {
        AppLogger.w(message: '⚠️ Failed to warm up ${entry.key}: $error');
      }
    });

    await Future.wait(futures);
    AppLogger.i(message: '🔥 Cache warmup completed');
  }

  /// Invalidates specific cache entry
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    AppLogger.d(message: '🗑️ Invalidated cache: $key');
  }

  /// Clears all cache
  Future<void> clear() async {
    _memoryCache.clear();
    _pendingRequests.clear();
    AppLogger.i(message: '🧹 Cache cleared');
  }

  /// Clears cache entries matching a pattern
  Future<void> clearByPattern(String pattern) async {
    final keysToRemove = <String>[];

    for (final key in _memoryCache.keys) {
      if (key.contains(pattern)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }

    AppLogger.i(
      message:
          '🧹 Cleared ${keysToRemove.length} cache entries matching pattern: $pattern',
    );
  }

  /// Gets cache statistics for monitoring
  CacheStats getStats() {
    final totalRequests = _hitCount + _staleHitCount + _missCount;
    final hitRate = totalRequests > 0
        ? ((_hitCount + _staleHitCount) / totalRequests) * 100
        : 0.0;

    return CacheStats(
      hitCount: _hitCount,
      staleHitCount: _staleHitCount,
      missCount: _missCount,
      hitRate: hitRate,
      evictionCount: _evictionCount,
      memoryCacheSize: _memoryCache.length,
      pendingRequestsCount: _pendingRequests.length,
    );
  }

  // Private methods

  void _putInMemory<T>(
    String key,
    T data, {
    required DateTime staleAt,
    required DateTime expiresAt,
  }) {
    // Remove if already exists
    _memoryCache.remove(key);

    // Add new entry
    _memoryCache[key] = _CacheEntry(data, staleAt: staleAt, expiresAt: expiresAt);

    // Enforce size limit with LRU eviction
    _evictIfNeeded();
  }

  void _evictIfNeeded() {
    while (_memoryCache.length > _maxMemoryCacheSize) {
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
      _evictionCount++;
      AppLogger.d(message: '🗑️ Evicted from memory cache: $firstKey');
    }
  }

  void _startMemoryPressureMonitoring() {
    _memoryPressureTimer = Timer.periodic(_memoryPressureCheckInterval, (_) {
      _handleMemoryPressure();
    });
  }

  void _handleMemoryPressure() {
    // In production, you could use platform channels to check actual memory usage
    // For now, we'll use a simple heuristic based on cache size

    final currentSize = _memoryCache.length;
    const maxSize = _maxMemoryCacheSize;

    if (currentSize > maxSize * 0.8) {
      // Cache is getting full, proactively remove expired entries
      final now = DateTime.now();
      final expiredKeys = _memoryCache.entries
          .where((entry) => now.isAfter(entry.value.expiresAt))
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredKeys) {
        _memoryCache.remove(key);
      }

      if (expiredKeys.isNotEmpty) {
        AppLogger.d(
          message: '🧹 Cleaned ${expiredKeys.length} expired entries',
        );
      }
    }
  }

  void dispose() {
    _memoryPressureTimer?.cancel();
    _memoryCache.clear();
    _pendingRequests.clear();
  }
}

class _CacheEntry {
  _CacheEntry(this.data, {required this.staleAt, required this.expiresAt});
  final dynamic data;

  /// When the entry stops being fresh and should be revalidated on next read.
  final DateTime staleAt;

  /// When the entry must no longer be served and counts as a miss.
  final DateTime expiresAt;
}

class CacheStats {
  CacheStats({
    required this.hitCount,
    required this.staleHitCount,
    required this.missCount,
    required this.hitRate,
    required this.evictionCount,
    required this.memoryCacheSize,
    required this.pendingRequestsCount,
  });
  final int hitCount;
  final int staleHitCount;
  final int missCount;
  final double hitRate;
  final int evictionCount;
  final int memoryCacheSize;
  final int pendingRequestsCount;

  @override
  String toString() {
    return 'CacheStats(fresh: $hitCount, stale: $staleHitCount, miss: $missCount, '
        'hitRate: ${hitRate.toStringAsFixed(2)}%, evictions: $evictionCount, '
        'memSize: $memoryCacheSize, pending: $pendingRequestsCount)';
  }
}

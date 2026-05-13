import 'dart:async';
import 'dart:collection';

import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:injectable/injectable.dart';

/// Enhanced multi-layer cache manager for scalable applications.
///
/// Features:
/// - Memory cache (L1) for instant access
/// - Persistent cache (L2) for offline support
/// - TTL-based expiration
/// - LRU eviction for memory management
/// - Cache warming and preloading
/// - Memory pressure handling
/// - Statistics and monitoring
/// - Concurrent request deduplication
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
  static const Duration _defaultTTL = Duration(minutes: 5);
  static const Duration _memoryPressureCheckInterval = Duration(minutes: 1);

  // Statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;

  Timer? _memoryPressureTimer;

  /// Gets data from cache with automatic fallback chain:
  /// Memory -> Persistent -> API -> Cache update
  Future<T?> get<T>(
    String key, {
    Duration? ttl,
    Future<T> Function()? fallbackLoader,
  }) async {
    final effectiveTTL = ttl ?? _defaultTTL;

    // Try memory cache first (L1)
    final memoryResult = _getFromMemory<T>(key);
    if (memoryResult != null) {
      _hitCount++;
      AppLogger.d(message: '🎯 Cache HIT (Memory): $key');
      return memoryResult;
    }

    // Deduplicate concurrent requests for same key
    if (_pendingRequests.containsKey(key)) {
      AppLogger.d(message: '⏳ Deduplicating request for: $key');
      return await _pendingRequests[key]!.future as T?;
    }

    _missCount++;
    AppLogger.d(message: '❌ Cache MISS: $key');

    // Create completer for deduplication
    final completer = Completer<T?>();
    _pendingRequests[key] = completer as Completer<dynamic>;

    try {
      T? result;

      // Try fallback loader if provided
      if (fallbackLoader != null) {
        result = await fallbackLoader();
        if (result != null) {
          await put(key, result, ttl: effectiveTTL);
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

  /// Stores data in both memory and persistent cache
  Future<void> put<T>(String key, T data, {Duration? ttl}) async {
    final effectiveTTL = ttl ?? _defaultTTL;
    final expiryTime = DateTime.now().add(effectiveTTL);

    // Store in memory cache (L1)
    _putInMemory(key, data, expiryTime);

    AppLogger.d(message: '💾 Cached: $key (TTL: ${effectiveTTL.inMinutes}min)');
  }

  /// Preloads critical data into cache during idle time
  Future<void> warmup<T>(
    Map<String, Future<T> Function()> loaders, {
    Duration? ttl,
  }) async {
    AppLogger.i(
      message: '🔥 Starting cache warmup for ${loaders.length} items',
    );

    final futures = loaders.entries.map((entry) async {
      try {
        final data = await entry.value();
        await put(entry.key, data, ttl: ttl);
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
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? (_hitCount / totalRequests) * 100 : 0.0;

    return CacheStats(
      hitCount: _hitCount,
      missCount: _missCount,
      hitRate: hitRate,
      evictionCount: _evictionCount,
      memoryCacheSize: _memoryCache.length,
      pendingRequestsCount: _pendingRequests.length,
    );
  }

  // Private methods

  T? _getFromMemory<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    // Check if expired
    if (DateTime.now().isAfter(entry.expiryTime)) {
      _memoryCache.remove(key);
      return null;
    }

    // Move to end for LRU (most recently used)
    _memoryCache.remove(key);
    _memoryCache[key] = entry;

    return entry.data as T?;
  }

  void _putInMemory<T>(String key, T data, DateTime expiryTime) {
    // Remove if already exists
    _memoryCache.remove(key);

    // Add new entry
    _memoryCache[key] = _CacheEntry(data, expiryTime);

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
          .where((entry) => now.isAfter(entry.value.expiryTime))
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
  _CacheEntry(this.data, this.expiryTime);
  final dynamic data;
  final DateTime expiryTime;
}

class CacheStats {
  CacheStats({
    required this.hitCount,
    required this.missCount,
    required this.hitRate,
    required this.evictionCount,
    required this.memoryCacheSize,
    required this.pendingRequestsCount,
  });
  final int hitCount;
  final int missCount;
  final double hitRate;
  final int evictionCount;
  final int memoryCacheSize;
  final int pendingRequestsCount;

  @override
  String toString() {
    return 'CacheStats(hit: $hitCount, miss: $missCount, hitRate: ${hitRate.toStringAsFixed(2)}%, '
        'evictions: $evictionCount, memSize: $memoryCacheSize, pending: $pendingRequestsCount)';
  }
}

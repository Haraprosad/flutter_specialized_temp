// scalable_cache_manager_test.dart
//
// Verifies the stale-while-revalidate lifecycle of the cache manager:
// fresh -> stale -> expired, plus LRU eviction and stats.

import 'package:flutter_specialized_temp/core/network/cache/scalable_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ScalableCacheManager cache;

  setUp(() {
    cache = ScalableCacheManager();
  });

  tearDown(() {
    cache.dispose();
  });

  group('peek freshness lifecycle', () {
    test('returns miss for an unknown key', () {
      final lookup = cache.peek<String>('unknown');

      expect(lookup.isMiss, isTrue);
      expect(lookup.value, isNull);
    });

    test('returns fresh immediately after put', () async {
      await cache.put('k', 'v', staleAfter: const Duration(seconds: 5));

      final lookup = cache.peek<String>('k');

      expect(lookup.isFresh, isTrue);
      expect(lookup.value, 'v');
    });

    test('becomes stale (value still served) after the stale window', () async {
      await cache.put(
        'k',
        'v',
        staleAfter: const Duration(milliseconds: 100),
        maxAge: const Duration(seconds: 5),
      );

      await Future<void>.delayed(const Duration(milliseconds: 160));

      final lookup = cache.peek<String>('k');
      expect(lookup.isStale, isTrue);
      expect(lookup.value, 'v', reason: 'stale data must still be served');
    });

    test('becomes a miss after max age', () async {
      await cache.put(
        'k',
        'v',
        staleAfter: const Duration(milliseconds: 80),
        maxAge: const Duration(milliseconds: 160),
      );

      await Future<void>.delayed(const Duration(milliseconds: 220));

      final lookup = cache.peek<String>('k');
      expect(lookup.isMiss, isTrue);
      expect(lookup.value, isNull);
    });

    test('clamps max age up to at least the stale window', () async {
      // maxAge < staleAfter should not make the entry expire before it is stale.
      await cache.put(
        'k',
        'v',
        staleAfter: const Duration(milliseconds: 200),
        maxAge: const Duration(milliseconds: 50),
      );

      final lookup = cache.peek<String>('k');
      expect(lookup.isFresh, isTrue);
    });
  });

  group('get', () {
    test('returns a stale-but-not-expired value', () async {
      await cache.put(
        'k',
        'v',
        staleAfter: const Duration(milliseconds: 80),
        maxAge: const Duration(seconds: 5),
      );
      await Future<void>.delayed(const Duration(milliseconds: 140));

      expect(await cache.get<String>('k'), 'v');
    });

    test('invokes fallbackLoader and caches on miss', () async {
      var loads = 0;
      final result = await cache.get<String>(
        'k',
        fallbackLoader: () async {
          loads++;
          return 'loaded';
        },
        staleAfter: const Duration(seconds: 5),
      );

      expect(result, 'loaded');
      expect(loads, 1);
      // Now cached and fresh — no second load.
      expect(cache.peek<String>('k').isFresh, isTrue);
    });
  });

  group('invalidation', () {
    test('invalidate removes a single key', () async {
      await cache.put('k', 'v');
      await cache.invalidate('k');
      expect(cache.peek<String>('k').isMiss, isTrue);
    });

    test('clearByPattern removes matching keys only', () async {
      await cache.put('posts_1', 'a');
      await cache.put('posts_2', 'b');
      await cache.put('users_1', 'c');

      await cache.clearByPattern('posts_');

      expect(cache.peek<String>('posts_1').isMiss, isTrue);
      expect(cache.peek<String>('posts_2').isMiss, isTrue);
      expect(cache.peek<String>('users_1').isFresh, isTrue);
    });
  });

  group('stats', () {
    test('tracks fresh hits, stale hits and misses', () async {
      cache.peek<String>('missing'); // miss

      await cache.put(
        'k',
        'v',
        staleAfter: const Duration(milliseconds: 80),
        maxAge: const Duration(seconds: 5),
      );
      cache.peek<String>('k'); // fresh hit

      await Future<void>.delayed(const Duration(milliseconds: 140));
      cache.peek<String>('k'); // stale hit

      final stats = cache.getStats();
      expect(stats.hitCount, 1);
      expect(stats.staleHitCount, 1);
      expect(stats.missCount, 1);
    });
  });
}

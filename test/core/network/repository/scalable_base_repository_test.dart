// scalable_base_repository_test.dart
//
// Verifies stale-while-revalidate behaviour of optimizedApiCall:
// fresh reads skip the network, stale reads serve the cached value
// immediately while refreshing in the background, and misses fetch+wait.

import 'package:flutter_specialized_temp/core/localization/l10n/app_localizations.dart';
import 'package:flutter_specialized_temp/core/network/cache/scalable_cache_manager.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/network_error_handler.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import 'package:flutter_specialized_temp/core/network/repository/scalable_base_repository.dart';
import 'package:flutter_specialized_temp/core/network/services/localization_service/localization_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal localization that echoes the key — enough for error translation.
class _FakeLocalizationService implements LocalizationService {
  @override
  void setLocalizations(AppLocalizations localizations) {}

  @override
  String translate(String key) => key;
}

/// Concrete repository exposing [optimizedApiCall] for testing.
class _TestRepository extends ScalableBaseRepository {
  _TestRepository(super.errorHandler, super.cacheManager);

  Future<ApiResult<int>> load(
    Future<int> Function() apiCall, {
    Duration? staleTime,
    Duration? maxStaleAge,
    bool bypassCache = false,
  }) {
    return optimizedApiCall<int>(
      cacheKey: 'value',
      apiCall: apiCall,
      staleTime: staleTime,
      maxStaleAge: maxStaleAge,
      bypassCache: bypassCache,
    );
  }
}

void main() {
  late ScalableCacheManager cache;
  late _TestRepository repo;

  setUp(() {
    cache = ScalableCacheManager();
    repo = _TestRepository(NetworkErrorHandler(_FakeLocalizationService()), cache);
  });

  tearDown(() {
    cache.dispose();
  });

  int dataOf(ApiResult<int> result) => (result as ApiSuccess<int>).data;

  test('miss fetches and caches', () async {
    var calls = 0;
    final result = await repo.load(() async => ++calls);

    expect(dataOf(result), 1);
    expect(calls, 1);
  });

  test('fresh read skips the network', () async {
    var calls = 0;
    Future<int> api() async => ++calls;

    await repo.load(api, staleTime: const Duration(seconds: 5));
    final second = await repo.load(api, staleTime: const Duration(seconds: 5));

    expect(dataOf(second), 1);
    expect(calls, 1, reason: 'fresh cache must not hit the network');
  });

  test('stale read serves cached value immediately then revalidates', () async {
    var calls = 0;
    Future<int> api() async => ++calls;

    // Prime the cache (calls -> 1) with a short stale window.
    await repo.load(
      api,
      staleTime: const Duration(milliseconds: 100),
      maxStaleAge: const Duration(seconds: 5),
    );
    expect(calls, 1);

    // Let it go stale.
    await Future<void>.delayed(const Duration(milliseconds: 160));

    // Stale read returns the OLD value synchronously...
    final stale = await repo.load(
      api,
      staleTime: const Duration(milliseconds: 100),
      maxStaleAge: const Duration(seconds: 5),
    );
    expect(dataOf(stale), 1, reason: 'serves stale value instantly');

    // ...and a background refresh updates the cache (calls -> 2).
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(calls, 2, reason: 'background revalidation ran');

    final fresh = await repo.load(api, staleTime: const Duration(seconds: 5));
    expect(dataOf(fresh), 2, reason: 'next read gets the refreshed value');
  });

  test('bypassCache forces a fresh fetch', () async {
    var calls = 0;
    Future<int> api() async => ++calls;

    await repo.load(api, staleTime: const Duration(seconds: 5));
    final forced = await repo.load(
      api,
      staleTime: const Duration(seconds: 5),
      bypassCache: true,
    );

    expect(dataOf(forced), 2);
    expect(calls, 2);
  });
}

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Bounded image cache manager: 100 objects max, 7-day staleness.
///
/// Pass [AppImageCacheManager.instance] to every [CachedNetworkImage] call so
/// all image caching goes through a single, memory-bounded store instead of
/// the [DefaultCacheManager] (which has 200 objects / 30-day defaults).
class AppImageCacheManager extends CacheManager {
  static const String _cacheKey = 'app_image_cache';

  AppImageCacheManager._()
      : super(
          Config(
            _cacheKey,
            maxNrOfCacheObjects: 100,
            stalePeriod: const Duration(days: 7),
          ),
        );

  static final AppImageCacheManager instance = AppImageCacheManager._();
}

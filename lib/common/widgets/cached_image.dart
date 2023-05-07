import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';

/// A custom cache manager is needed to define exact image cap and stale period.
final _cacheManager = CacheManager(
  Config(
    'imageCache',
    maxNrOfCacheObjects: 1000,
    stalePeriod: const Duration(days: 10),
  ),
);

/// Erases image cache.
void clearImageCache() => _cacheManager.emptyCache();

/// A [CachedNetworkImage] wrapper that simplifies the interface
/// and uses the custom cache manager, without exposing it.
class CachedImage extends StatelessWidget {
  const CachedImage(
    this.imageUrl, {
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  final String imageUrl;
  final BoxFit fit;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      cacheManager: _cacheManager,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      errorWidget: (context, url, error) => IconButton(
        icon: const Icon(Icons.close_outlined),
        onPressed: () => Toast.show(context, 'Failed loading: $imageUrl'),
      ),
    );
  }
}

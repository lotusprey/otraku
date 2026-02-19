import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:otraku/localizations/gen.dart';

/// A custom cache manager is needed to define exact image cap and stale period.
final _cacheManager = CacheManager(
  Config('imageCache', maxNrOfCacheObjects: 1000, stalePeriod: const Duration(days: 10)),
);

/// Erases image cache.
void clearImageCache() => _cacheManager.emptyCache();

Future<File> getFileFromCacheOrDownload(String url) => _cacheManager.getSingleFile(url);

/// A [CachedNetworkImage] wrapper that simplifies the interface
/// and uses the custom cache manager, without exposing it.
class CachedImage extends StatelessWidget {
  const CachedImage(
    this.imageUrl, {
    this.fit = .cover,
    this.width = .infinity,
    this.height = .infinity,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

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
      errorWidget: (context, _, _) => Tooltip(
        triggerMode: .tap,
        message: AppLocalizations.of(context)!.errorFailedGettingFile,
        child: const Icon(Icons.error_outline_rounded),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/home/home_model.dart';

final homeProvider = NotifierProvider.autoDispose<HomeNotifier, Home>(
  HomeNotifier.new,
);

class HomeNotifier extends AutoDisposeNotifier<Home> {
  @override
  Home build() => Home(
        didExpandAnimeCollection: !Options().animeCollectionPreview,
        didExpandMangaCollection: !Options().mangaCollectionPreview,
      );

  void expandCollection(bool ofAnime) =>
      state = state.withExpandedCollection(ofAnime);

  void cacheSystemColorSchemes(
    ColorScheme? systemLightScheme,
    ColorScheme? systemDarkScheme,
  ) =>
      state = state.withSystemColorSchemes(systemLightScheme, systemDarkScheme);
}

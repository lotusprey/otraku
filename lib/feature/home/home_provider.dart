import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/feature/home/home_model.dart';

final homeProvider = NotifierProvider.autoDispose<HomeNotifier, Home>(
  HomeNotifier.new,
);

class HomeNotifier extends AutoDisposeNotifier<Home> {
  @override
  Home build() => Home(
        didExpandAnimeCollection: !Persistence().animeCollectionPreview,
        didExpandMangaCollection: !Persistence().mangaCollectionPreview,
      );

  void expandCollection(bool ofAnime) =>
      state = state.withExpandedCollection(ofAnime);

  void cacheSystemColorSchemes(
    Color? systemLightPrimaryColor,
    Color? systemDarkPrimaryColor,
  ) =>
      state = state.withSystemColorSchemes(
        systemLightPrimaryColor,
        systemDarkPrimaryColor,
      );
}

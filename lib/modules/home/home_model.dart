import 'package:flutter/material.dart';

class Home {
  const Home({
    required this.didExpandAnimeCollection,
    required this.didExpandMangaCollection,
    this.systemLightPrimaryColor,
    this.systemDarkPrimaryColor,
  });

  /// In preview mode, user's collections first load only current media.
  /// The rest is loaded by a manual request from the user
  /// and thus the collection "expands".
  /// If preview mode is off, collections are auto-expanded
  /// and immediately load everything.
  final bool didExpandAnimeCollection;
  final bool didExpandMangaCollection;

  /// The system primary colors acquired asynchronously
  /// from [DynamicColorBuilder] are cached.
  final Color? systemLightPrimaryColor;
  final Color? systemDarkPrimaryColor;

  Home withExpandedCollection(bool ofAnime) => ofAnime
      ? Home(
          didExpandAnimeCollection: true,
          didExpandMangaCollection: didExpandMangaCollection,
          systemLightPrimaryColor: systemLightPrimaryColor,
          systemDarkPrimaryColor: systemDarkPrimaryColor,
        )
      : Home(
          didExpandAnimeCollection: didExpandAnimeCollection,
          didExpandMangaCollection: true,
          systemLightPrimaryColor: systemLightPrimaryColor,
          systemDarkPrimaryColor: systemDarkPrimaryColor,
        );

  Home withSystemColorSchemes(
    Color? systemLightPrimaryColor,
    Color? systemDarkPrimaryColor,
  ) =>
      Home(
        didExpandAnimeCollection: didExpandAnimeCollection,
        didExpandMangaCollection: didExpandMangaCollection,
        systemLightPrimaryColor: systemLightPrimaryColor,
        systemDarkPrimaryColor: systemDarkPrimaryColor,
      );
}

enum HomeTab {
  feed('Feed'),
  anime('Anime'),
  manga('Manga'),
  discover('Discover'),
  profile('Profile');

  const HomeTab(this.label);

  final String label;
}

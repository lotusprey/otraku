import 'package:flutter/material.dart';

class Home {
  const Home({
    required this.didExpandAnimeCollection,
    required this.didExpandMangaCollection,
    this.systemLightScheme,
    this.systemDarkScheme,
  });

  /// In preview mode, user's collections first load only current media.
  /// The rest is loaded by a manual request from the user
  /// and thus the collection "expands".
  /// If preview mode is off, collections are auto-expanded
  /// and immediately load everything.
  final bool didExpandAnimeCollection;
  final bool didExpandMangaCollection;

  /// The system schemes acquired asynchronously
  /// from [DynamicColorBuilder] are cached.
  final ColorScheme? systemLightScheme;
  final ColorScheme? systemDarkScheme;

  Home withExpandedCollection(bool ofAnime) => ofAnime
      ? Home(
          didExpandAnimeCollection: true,
          didExpandMangaCollection: didExpandMangaCollection,
          systemLightScheme: systemLightScheme,
          systemDarkScheme: systemDarkScheme,
        )
      : Home(
          didExpandAnimeCollection: didExpandAnimeCollection,
          didExpandMangaCollection: true,
          systemLightScheme: systemLightScheme,
          systemDarkScheme: systemDarkScheme,
        );

  Home withSystemColorSchemes(
    ColorScheme? systemLightScheme,
    ColorScheme? systemDarkScheme,
  ) =>
      Home(
        didExpandAnimeCollection: didExpandAnimeCollection,
        didExpandMangaCollection: didExpandMangaCollection,
        systemLightScheme: systemLightScheme,
        systemDarkScheme: systemDarkScheme,
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

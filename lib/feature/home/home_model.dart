class Home {
  const Home({
    required this.didExpandAnimeCollection,
    required this.didExpandMangaCollection,
  });

  /// In preview mode, user's collections first load only current media.
  /// The rest is loaded by a manual request from the user
  /// and thus the collection "expands".
  /// If preview mode is off, collections are auto-expanded
  /// and immediately load everything.
  final bool didExpandAnimeCollection;
  final bool didExpandMangaCollection;

  Home withExpandedCollection(bool ofAnime) => ofAnime
      ? Home(
          didExpandAnimeCollection: true,
          didExpandMangaCollection: didExpandMangaCollection,
        )
      : Home(
          didExpandAnimeCollection: didExpandAnimeCollection,
          didExpandMangaCollection: true,
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

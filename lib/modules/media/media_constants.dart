enum MediaStatus {
  FINISHED,
  RELEASING,
  HIATUS,
  NOT_YET_RELEASED,
  CANCELLED,
}

enum AnimeFormat {
  TV,
  TV_SHORT,
  MOVIE,
  SPECIAL,
  OVA,
  ONA,
  MUSIC;

  static AnimeFormat? fromText(String? text) => switch (text) {
        'Tv' => AnimeFormat.TV,
        'Tv Short' => AnimeFormat.TV_SHORT,
        'Movie' => AnimeFormat.MOVIE,
        'Special' => AnimeFormat.SPECIAL,
        'Ova' => AnimeFormat.OVA,
        'Ona' => AnimeFormat.ONA,
        'Music' => AnimeFormat.MUSIC,
        _ => null,
      };
}

enum MangaFormat {
  MANGA,
  NOVEL,
  ONE_SHOT;

  static MangaFormat? fromText(String? text) => switch (text) {
        'Manga' => MangaFormat.MANGA,
        'Novel' => MangaFormat.NOVEL,
        'One Shot' => MangaFormat.ONE_SHOT,
        _ => null,
      };
}

enum MediaSeason {
  WINTER,
  SPRING,
  SUMMER,
  FALL,
}

enum ScoreFormat {
  POINT_100,
  POINT_10_DECIMAL,
  POINT_10,
  POINT_5,
  POINT_3,
}

enum MediaSource {
  ORIGINAL,
  MANGA,
  LIGHT_NOVEL,
  VISUAL_NOVEL,
  VIDEO_GAME,
  OTHER,
  NOVEL,
  DOUJINSHI,
  ANIME,
  WEB_NOVEL,
  LIVE_ACTION,
  GAME,
  COMIC,
  MULTIMEDIA_PROJECT,
  PICTURE_BOOK,
}

enum OriginCountry {
  JAPAN('JP'),
  CHINA('CN'),
  SOUTH_KOREA('KR'),
  TAIWAN('TW');

  const OriginCountry(this.code);

  final String code;
}

enum MediaSort {
  TRENDING_DESC('Trending'),
  POPULARITY_DESC('Popularity'),
  SCORE_DESC('Score'),
  SCORE('Worst Score'),
  FAVOURITES_DESC('Favourites'),
  START_DATE_DESC('Released Latest'),
  START_DATE('Released Earliest'),
  ID_DESC('Last Added'),
  ID('First Added'),
  TITLE_ROMAJI('Title Romaji'),
  TITLE_ENGLISH('Title English'),
  TITLE_NATIVE('Title Native');

  const MediaSort(this.label);

  final String label;
}

enum EntrySort {
  TITLE('Title'),
  TITLE_DESC('Title Z-A'),
  SCORE('Worst Score'),
  SCORE_DESC('Best Score'),
  UPDATED('Updated'),
  UPDATED_DESC('Last Updated'),
  ADDED('Added'),
  ADDED_DESC('Last Added'),
  AIRING('Airing'),
  AIRING_DESC('Last Airing'),
  STARTED_ON('Started'),
  STARTED_ON_DESC('Last Started'),
  COMPLETED_ON('Completed'),
  COMPLETED_ON_DESC('Last Completed'),
  RELEASED_ON('Release'),
  RELEASED_ON_DESC('Last Release'),
  PROGRESS('Least Progress'),
  PROGRESS_DESC('Most Progress'),
  AVG_SCORE('Lowest Rated'),
  AVG_SCORE_DESC('Highest Rated'),
  REPEATED('Least Repeated'),
  REPEATED_DESC('Most Repeated');

  const EntrySort(this.label);

  /// Human readable name.
  final String label;

  /// The API supports only few default sortings.
  static const rowOrders = [
    EntrySort.SCORE_DESC,
    EntrySort.TITLE,
    EntrySort.UPDATED_DESC,
    EntrySort.ADDED_DESC,
  ];

  /// Format as an API row order.
  String toRowOrder() => switch (this) {
        EntrySort.SCORE_DESC => 'score',
        EntrySort.UPDATED_DESC => 'updatedAt',
        EntrySort.ADDED_DESC => 'id',
        EntrySort.TITLE => 'title',
        _ => 'title',
      };

  /// Translate API row order to general sorting.
  static EntrySort fromRowOrder(String key) => switch (key) {
        'score' => EntrySort.SCORE_DESC,
        'updatedAt' => EntrySort.UPDATED_DESC,
        'id' => EntrySort.ADDED_DESC,
        'title' => EntrySort.TITLE,
        _ => EntrySort.TITLE,
      };
}

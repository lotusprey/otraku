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
  MUSIC,
}

enum MangaFormat {
  MANGA,
  NOVEL,
  ONE_SHOT,
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
  ID_DESC('Newest'),
  ID('Oldest'),
  FAVOURITES_DESC('Favourites'),
  START_DATE_DESC('Released Latest'),
  START_DATE('Released Earliest'),
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
  String toRowOrder() {
    switch (this) {
      case EntrySort.SCORE_DESC:
        return 'score';
      case EntrySort.UPDATED_DESC:
        return 'updatedAt';
      case EntrySort.ADDED_DESC:
        return 'id';
      case EntrySort.TITLE:
        return 'title';
      default:
        return 'title';
    }
  }

  /// Translate API row order to general sorting.
  static EntrySort fromRowOrder(String key) {
    switch (key) {
      case 'score':
        return EntrySort.SCORE_DESC;
      case 'updatedAt':
        return EntrySort.UPDATED_DESC;
      case 'id':
        return EntrySort.ADDED_DESC;
      case 'title':
        return EntrySort.TITLE;
      default:
        return EntrySort.TITLE;
    }
  }
}

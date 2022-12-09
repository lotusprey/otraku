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
  JAPAN,
  CHINA,
  SOUTH_KOREA,
  TAIWAN;

  String get code {
    switch (this) {
      case OriginCountry.JAPAN:
        return 'JP';
      case OriginCountry.CHINA:
        return 'CN';
      case OriginCountry.SOUTH_KOREA:
        return 'KR';
      case OriginCountry.TAIWAN:
        return 'TW';
    }
  }
}

enum MediaSort {
  ID,
  ID_DESC,
  TRENDING,
  TRENDING_DESC,
  POPULARITY,
  POPULARITY_DESC,
  FAVOURITES,
  FAVOURITES_DESC,
  SCORE,
  SCORE_DESC,
  START_DATE,
  START_DATE_DESC,
  END_DATE,
  END_DATE_DESC,
  TITLE_ROMAJI,
  TITLE_ROMAJI_DESC,
  TITLE_ENGLISH,
  TITLE_ENGLISH_DESC,
  TITLE_NATIVE,
  TITLE_NATIVE_DESC,
}

enum EntrySort {
  TITLE('Title'),
  TITLE_DESC('Title Z-A'),
  SCORE_DESC('Score'),
  SCORE('Worst Score'),
  UPDATED_AT_DESC('Last Updated'),
  UPDATED_AT('Updated'),
  ADDED_AT_DESC('Last Added'),
  ADDED_AT('Added'),
  AIRING_AT('Airing'),
  AIRING_AT_DESC('Airing Last'),
  PROGRESS_DESC('Most Progress'),
  PROGRESS('Least Progress'),
  REPEATED_DESC('Most Repeated'),
  REPEATED('Least Repeated'),
  RELEASE_START('Release Start'),
  RELEASE_START_DESC('Last Release Start'),
  RELEASE_END('Release End'),
  RELEASE_END_DESC('Last Release End'),
  STARTED_ON('Started'),
  STARTED_ON_DESC('Last Started'),
  COMPLETED_ON('Completed'),
  COMPLETED_ON_DESC('Last Completed');

  const EntrySort(this.label);

  /// Human readable name.
  final String label;

  /// The API supports only few default sortings.
  static const rowOrders = [
    EntrySort.SCORE_DESC,
    EntrySort.TITLE,
    EntrySort.UPDATED_AT_DESC,
    EntrySort.ADDED_AT_DESC,
  ];

  /// Format as an API row order.
  String toRowOrder() {
    switch (this) {
      case EntrySort.SCORE_DESC:
        return 'score';
      case EntrySort.UPDATED_AT_DESC:
        return 'updatedAt';
      case EntrySort.ADDED_AT_DESC:
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
        return EntrySort.UPDATED_AT_DESC;
      case 'id':
        return EntrySort.ADDED_AT_DESC;
      case 'title':
        return EntrySort.TITLE;
      default:
        return EntrySort.TITLE;
    }
  }
}

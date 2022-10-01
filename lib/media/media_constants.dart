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
  TITLE,
  TITLE_DESC,
  SCORE,
  SCORE_DESC,
  UPDATED_AT,
  UPDATED_AT_DESC,
  CREATED_AT,
  CREATED_AT_DESC,
  PROGRESS,
  PROGRESS_DESC,
  REPEAT,
  REPEAT_DESC,
  AIRING_AT,
  AIRING_AT_DESC,
  STARTED_RELEASING,
  STARTED_RELEASING_DESC,
  ENDED_RELEASING,
  ENDED_RELEASING_DESC,
  STARTED_WATCHING,
  STARTED_WATCHING_DESC,
  ENDED_WATCHING,
  ENDED_WATCHING_DESC;

  String get getString {
    switch (this) {
      case EntrySort.SCORE_DESC:
        return 'score';
      case EntrySort.UPDATED_AT_DESC:
        return 'updatedAt';
      case EntrySort.CREATED_AT_DESC:
        return 'id';
      case EntrySort.TITLE:
        return 'title';
      default:
        return 'title';
    }
  }

  static EntrySort getEnum(String key) {
    switch (key) {
      case 'score':
        return EntrySort.SCORE_DESC;
      case 'updatedAt':
        return EntrySort.UPDATED_AT_DESC;
      case 'id':
        return EntrySort.CREATED_AT_DESC;
      case 'title':
        return EntrySort.TITLE;
      default:
        return EntrySort.TITLE;
    }
  }

  static const defaultEnums = [
    EntrySort.TITLE,
    EntrySort.SCORE_DESC,
    EntrySort.UPDATED_AT_DESC,
    EntrySort.CREATED_AT_DESC,
  ];

  static const defaultStrings = [
    'Title',
    'Score',
    'Last Updated',
    'Last Added',
  ];
}

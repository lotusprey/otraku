// Used for sorting the entries of a collection.
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
  ENDED_WATCHING_DESC,
}

// AniList supports only 4 default sort types.
extension EntrySortHelper on EntrySort {
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

enum ListSort {
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
}

extension ListSortHelper on ListSort {
  static const _enumsToStrings = const {
    ListSort.TITLE: 'title',
    ListSort.SCORE_DESC: 'score',
    ListSort.UPDATED_AT_DESC: 'updatedAt',
    ListSort.CREATED_AT_DESC: 'id',
  };

  static const _stringsToEnums = const {
    'title': ListSort.TITLE,
    'score': ListSort.SCORE_DESC,
    'updatedAt': ListSort.UPDATED_AT_DESC,
    'id': ListSort.CREATED_AT_DESC,
  };

  String get string => _enumsToStrings[this];

  static ListSort getEnum(String key) => _stringsToEnums[key];

  static List<ListSort> get defaultEnums => [..._enumsToStrings.keys];

  static List<String> get defaultStrings =>
      const ['Title', 'Score', 'Last Updated', 'Last Added'];
}

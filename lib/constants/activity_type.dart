enum ActivityType {
  TEXT,
  ANIME_LIST,
  MANGA_LIST,
  MESSAGE,
}

extension ActivityTypeExtension on ActivityType {
  static const _activityNames = const {
    ActivityType.TEXT: 'Statuses',
    ActivityType.ANIME_LIST: 'Anime Progress',
    ActivityType.MANGA_LIST: 'Manga Progress',
    ActivityType.MESSAGE: 'Messages',
  };

  String get text => _activityNames[this]!;
}

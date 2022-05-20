enum ActivityType {
  TEXT,
  ANIME_LIST,
  MANGA_LIST,
  MESSAGE;

  String get text {
    switch (this) {
      case ActivityType.TEXT:
        return 'Statuses';
      case ActivityType.ANIME_LIST:
        return 'Anime Progress';
      case ActivityType.MANGA_LIST:
        return 'Manga Progress';
      case ActivityType.MESSAGE:
        return 'Messages';
    }
  }
}

import 'package:flutter/foundation.dart';

enum MediaListStatus {
  CURRENT,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REPEATING,
}

enum AnimeListStatus {
  WATCHING,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REWATCHING,
}

enum MangaListStatus {
  READING,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REREADING,
}

//An enum clarification function
String listStatusSpecification(MediaListStatus status, bool isAnime) {
  if (status == MediaListStatus.CURRENT) {
    if (isAnime) {
      return 'Watching';
    }
    return 'Reading';
  }

  if (status == MediaListStatus.REPEATING) {
    if (isAnime) {
      return 'Rewatching';
    }
    return 'Rereading';
  }

  String str = describeEnum(status);
  return str[0] + str.substring(1).toLowerCase();
}

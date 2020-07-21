import 'package:otraku/models/tuple.dart';

enum MediaSort {
  TRENDING,
  TRENDING_DESC,
  POPULARITY,
  POPULARITY_DESC,
  SCORE,
  SCORE_DESC,
  START_DATE,
  START_DATE_DESC,
  TITLE_ROMAJI,
  TITLE_ROMAJI_DESC,
  TITLE_ENGLISH,
  TITLE_ENGLISH_DESC,
  TITLE_NATIVE,
  TITLE_NATIVE_DESC,
}

extension MediaSortExtension on MediaSort {
  static const _sort = {
    MediaSort.TRENDING: Tuple('Trending', false),
    MediaSort.TRENDING_DESC: Tuple('Trending', true),
    MediaSort.POPULARITY: Tuple('Popularity', false),
    MediaSort.POPULARITY_DESC: Tuple('Popularity', true),
    MediaSort.SCORE: Tuple('Score', false),
    MediaSort.SCORE_DESC: Tuple('Score', true),
    MediaSort.START_DATE: Tuple('Start Date', false),
    MediaSort.START_DATE_DESC: Tuple('Start Date', true),
    MediaSort.TITLE_ROMAJI: Tuple('Title Romaji', false),
    MediaSort.TITLE_ROMAJI_DESC: Tuple('Title Romaji', true),
    MediaSort.TITLE_ENGLISH: Tuple('Title English', false),
    MediaSort.TITLE_ENGLISH_DESC: Tuple('Title English', true),
    MediaSort.TITLE_NATIVE: Tuple('Title Native', false),
    MediaSort.TITLE_NATIVE_DESC: Tuple('Title Native', true),
  };

  Tuple get tuple {
    return _sort[this];
  }
}

MediaSort getMediaSortFromString(String s) {
  switch (s) {
    case 'TRENDING':
      return MediaSort.TRENDING;
    case 'TRENDING_DESC':
      return MediaSort.TRENDING_DESC;
    case 'POPULARITY':
      return MediaSort.POPULARITY;
    case 'POPULARITY_DESC':
      return MediaSort.POPULARITY_DESC;
    case 'SCORE':
      return MediaSort.SCORE;
    case 'SCORE_DESC':
      return MediaSort.SCORE_DESC;
    case 'START_DATE':
      return MediaSort.START_DATE;
    case 'START_DATE_DESC':
      return MediaSort.START_DATE_DESC;
    case 'TITLE_ROMAJI':
      return MediaSort.TITLE_ROMAJI;
    case 'TITLE_ROMAJI_DESC':
      return MediaSort.TITLE_ROMAJI_DESC;
    case 'TITLE_ENGLISH':
      return MediaSort.TITLE_ENGLISH;
    case 'TITLE_ENGLISH_DESC':
      return MediaSort.TITLE_ENGLISH_DESC;
    case 'TITLE_NATIVE':
      return MediaSort.TITLE_NATIVE;
    case 'TITLE_NATIVE_DESC':
      return MediaSort.TITLE_NATIVE_DESC;
    default:
      throw Exception('Could not convert from string to MediaSort enum');
  }
}

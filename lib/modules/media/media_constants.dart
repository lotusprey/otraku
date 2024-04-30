import 'package:otraku/common/utils/extensions.dart';

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
        'Tv' => TV,
        'Tv Short' => TV_SHORT,
        'Movie' => MOVIE,
        'Special' => SPECIAL,
        'Ova' => OVA,
        'Ona' => ONA,
        'Music' => MUSIC,
        _ => null,
      };
}

enum MangaFormat {
  MANGA,
  NOVEL,
  ONE_SHOT;

  static MangaFormat? fromLabel(String? s) => switch (s) {
        'Manga' => MANGA,
        'Novel' => NOVEL,
        'One Shot' => ONE_SHOT,
        _ => null,
      };
}

enum MediaSeason {
  winter('Winter', 'WINTER'),
  spring('Spring', 'SPRING'),
  summer('Summer', 'SUMMER'),
  fall('Fall', 'FALL');

  const MediaSeason(this.label, this.value);

  final String label;
  final String value;

  static MediaSeason? from(String? value) =>
      MediaSeason.values.firstWhereOrNull((v) => v.value == value);
}

enum ScoreFormat {
  point100('100 Points', 'POINT_100'),
  point10Decimal('10 Decimal Points', 'POINT_10_DECIMAL'),
  point10('10 Points', 'POINT_10'),
  point5('5 Stars', 'POINT_5'),
  point3('3 Smileys', 'POINT_3');

  const ScoreFormat(this.label, this.value);

  final String label;
  final String value;

  static ScoreFormat from(String? value) => ScoreFormat.values.firstWhere(
        (v) => v.value == value,
        orElse: () => point10,
      );
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
  japan('Japan', 'JP'),
  china('China', 'CN'),
  southKorea('South Korea', 'KR'),
  taiwan('Taiwan', 'TW');

  const OriginCountry(this.label, this.code);

  final String label;
  final String code;

  static OriginCountry? fromCode(String? code) =>
      OriginCountry.values.firstWhereOrNull((v) => v.code == code);
}

enum MediaSort {
  trendingDesc('Trending', 'TRENDING_DESC'),
  popularityDesc('Popularity', 'POPULARITY_DESC'),
  scoreDesc('Score', 'SCORE_DESC'),
  score('Worst Score', 'SCORE'),
  favoritesDesc('Favourites', 'FAVOURITES_DESC'),
  startDateDesc('Released Latest', 'START_DATE_DESC'),
  startDate('Released Earliest', 'START_DATE'),
  idDesc('Last Added', 'ID_DESC'),
  id('First Added', 'ID'),
  titleRomaji('Title Romaji', 'TITLE_ROMAJI'),
  titleEnglish('Title English', 'TITLE_ENGLISH'),
  titleNative('Title Native', 'TITLE_NATIVE');

  const MediaSort(this.label, this.value);

  final String label;
  final String value;
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

  final String label;

  /// The API supports only few default sortings.
  static const rowOrders = [SCORE_DESC, TITLE, UPDATED_DESC, ADDED_DESC];

  /// Format as an API row order.
  String toRowOrder() => switch (this) {
        SCORE_DESC => 'score',
        UPDATED_DESC => 'updatedAt',
        ADDED_DESC => 'id',
        TITLE => 'title',
        _ => 'title',
      };

  /// Translate API row order to general sorting.
  static EntrySort fromRowOrder(String key) => switch (key) {
        'score' => SCORE_DESC,
        'updatedAt' => UPDATED_DESC,
        'id' => ADDED_DESC,
        'title' => TITLE,
        _ => TITLE,
      };
}

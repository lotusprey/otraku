import 'package:otraku/extension/enum_extension.dart';
import 'package:otraku/feature/collection/collection_filter_model.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/review/review_models.dart';

class DiscoverFilter {
  const DiscoverFilter._({
    required this.type,
    required this.search,
    required this.mediaFilter,
    required this.hasBirthday,
    required this.reviewsFilter,
    required this.recommendationsFilter,
  });

  DiscoverFilter(this.type, this.mediaFilter)
    : search = '',
      hasBirthday = false,
      reviewsFilter = const ReviewsFilter(),
      recommendationsFilter = const DiscoverRecommendationsFilter();

  final DiscoverType type;
  final String search;
  final DiscoverMediaFilter mediaFilter;
  final bool hasBirthday;
  final ReviewsFilter reviewsFilter;
  final DiscoverRecommendationsFilter recommendationsFilter;

  DiscoverFilter copyWith({
    DiscoverType? type,
    String? search,
    DiscoverMediaFilter? mediaFilter,
    bool? hasBirthday,
    ReviewsFilter? reviewsFilter,
    DiscoverRecommendationsFilter? recommendationsFilter,
  }) => DiscoverFilter._(
    type: type ?? this.type,
    search: search ?? this.search,
    mediaFilter: mediaFilter ?? this.mediaFilter,
    hasBirthday: hasBirthday ?? this.hasBirthday,
    reviewsFilter: reviewsFilter ?? this.reviewsFilter,
    recommendationsFilter: recommendationsFilter ?? this.recommendationsFilter,
  );
}

class DiscoverMediaFilter {
  DiscoverMediaFilter(this.sort);

  factory DiscoverMediaFilter.fromPersistenceMap(Map<dynamic, dynamic> map) {
    final sort = MediaSort.values.getOrFirst(map['sort']);

    final filter = DiscoverMediaFilter(sort)
      ..season = MediaSeason.values.getOrNull(map['season'])
      ..startYearFrom = map['startYearFrom']
      ..startYearTo = map['startYearTo']
      ..country = OriginCountry.values.getOrNull(map['country'])
      ..inLists = map['inLists']
      ..isAdult = map['isAdult']
      ..isLicensed = map['isLicensed'];

    for (final e in map['statuses'] ?? const []) {
      final status = ReleaseStatus.values.getOrNull(e);
      if (status != null) {
        filter.statuses.add(status);
      }
    }

    for (final e in map['animeFormats'] ?? const []) {
      final format = MediaFormat.values.getOrNull(e);
      if (format != null) {
        filter.animeFormats.add(format);
      }
    }

    for (final e in map['mangaFormats'] ?? const []) {
      final format = MediaFormat.values.getOrNull(e);
      if (format != null) {
        filter.mangaFormats.add(format);
      }
    }

    for (final e in map['sources'] ?? const []) {
      final source = MediaSource.values.getOrNull(e);
      if (source != null) {
        filter.sources.add(source);
      }
    }

    for (final e in (map['mangaLicensorIdIn'] ?? const {}).entries) {
      if (e.value is List<int>) {
        filter.mangaLicensorIdIn.add((language: e.key.toString(), ids: e.value));
      }
    }

    filter.genreIn.addAll(map['genreIn'] ?? const []);
    filter.genreNotIn.addAll(map['genreNotIn'] ?? const []);
    filter.tagIn.addAll(map['tagIn'] ?? const []);
    filter.tagNotIn.addAll(map['tagNotIn'] ?? const []);
    filter.animeLicensorIdIn.addAll(map['animeLicensorIdIn'] ?? const []);

    return filter;
  }

  final statuses = <ReleaseStatus>[];
  final animeFormats = <MediaFormat>[];
  final mangaFormats = <MediaFormat>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  final sources = <MediaSource>[];
  final animeLicensorIdIn = <int>[];
  final mangaLicensorIdIn = <({String language, List<int> ids})>[];
  MediaSort sort;
  MediaSeason? season;
  int? startYearFrom;
  int? startYearTo;
  OriginCountry? country;
  bool? inLists;
  bool? isAdult;
  bool? isLicensed;

  bool get isActive =>
      statuses.isNotEmpty ||
      animeFormats.isNotEmpty ||
      mangaFormats.isNotEmpty ||
      genreIn.isNotEmpty ||
      genreNotIn.isNotEmpty ||
      tagIn.isNotEmpty ||
      tagNotIn.isNotEmpty ||
      sources.isNotEmpty ||
      animeLicensorIdIn.isNotEmpty ||
      mangaLicensorIdIn.isNotEmpty ||
      season != null ||
      startYearFrom != null ||
      startYearTo != null ||
      country != null ||
      inLists != null ||
      isAdult != null ||
      isLicensed != null;

  DiscoverMediaFilter copy() => DiscoverMediaFilter(sort)
    ..statuses.addAll(statuses)
    ..animeFormats.addAll(animeFormats)
    ..mangaFormats.addAll(mangaFormats)
    ..genreIn.addAll(genreIn)
    ..genreNotIn.addAll(genreNotIn)
    ..tagIn.addAll(tagIn)
    ..tagNotIn.addAll(tagNotIn)
    ..sources.addAll(sources)
    ..animeLicensorIdIn.addAll(animeLicensorIdIn)
    ..mangaLicensorIdIn.addAll(
      mangaLicensorIdIn.map((it) => (language: it.language, ids: [...it.ids])),
    )
    ..season = season
    ..startYearFrom = startYearFrom
    ..startYearTo = startYearTo
    ..country = country
    ..inLists = inLists
    ..isAdult = isAdult
    ..isLicensed = isLicensed;

  static DiscoverMediaFilter fromCollection({
    required CollectionMediaFilter filter,
    required MediaSort sort,
    required bool ofAnime,
  }) => DiscoverMediaFilter(sort)
    ..statuses.addAll(filter.statuses)
    ..animeFormats.addAll(ofAnime ? filter.formats : const [])
    ..mangaFormats.addAll(!ofAnime ? filter.formats : const [])
    ..genreIn.addAll(filter.genreIn)
    ..genreNotIn.addAll(filter.genreNotIn)
    ..tagIn.addAll(filter.tagIn)
    ..tagNotIn.addAll(filter.tagNotIn)
    ..startYearFrom = filter.startYearFrom
    ..startYearTo = filter.startYearTo
    ..country = filter.country;

  Map<String, dynamic> toGraphQlVariables({required bool ofAnime}) => {
    'sort': sort.value,
    if (ofAnime && animeFormats.isNotEmpty) 'format_in': animeFormats.map((v) => v.value).toList(),
    if (!ofAnime && mangaFormats.isNotEmpty) 'format_in': mangaFormats.map((v) => v.value).toList(),
    if (statuses.isNotEmpty) 'status_in': statuses.map((v) => v.value).toList(),
    if (sources.isNotEmpty) 'sources': sources.map((v) => v.value).toList(),
    if (ofAnime && season != null) 'season': season!.value,
    if (genreIn.isNotEmpty) 'genre_in': genreIn,
    if (genreNotIn.isNotEmpty) 'genre_not_in': genreNotIn,
    if (tagIn.isNotEmpty) 'tag_in': tagIn,
    if (tagNotIn.isNotEmpty) 'tag_not_in': tagNotIn,
    if (ofAnime && animeLicensorIdIn.isNotEmpty) 'licensor_id_in': animeLicensorIdIn,
    if (!ofAnime && mangaLicensorIdIn.isNotEmpty)
      'licensor_id_in': mangaLicensorIdIn.expand((it) => it.ids).toList(),
    if (startYearFrom != null) 'startFrom': '${startYearFrom! - 1}9999',
    if (startYearTo != null) 'startTo': '${startYearTo! + 1}0000',
    if (country != null) 'countryOfOrigin': country!.code,
    if (inLists != null) 'onList': inLists,
    if (isAdult != null) 'isAdult': isAdult,
    if (isLicensed != null) 'isLicensed': isLicensed,
  };

  Map<String, dynamic> toPersistenceMap() => {
    'statuses': statuses.map((e) => e.index).toList(),
    'animeFormats': animeFormats.map((e) => e.index).toList(),
    'mangaFormats': mangaFormats.map((e) => e.index).toList(),
    'genreIn': genreIn,
    'genreNotIn': genreNotIn,
    'tagIn': tagIn,
    'tagNotIn': tagNotIn,
    'sources': sources.map((e) => e.index).toList(),
    'animeLicensorIdIn': animeLicensorIdIn,
    'mangaLicensorIdIn': {for (final it in mangaLicensorIdIn) it.language: it.ids},
    'sort': sort.index,
    'season': season?.index,
    'startYearFrom': startYearFrom,
    'startYearTo': startYearTo,
    'country': country?.index,
    'inLists': inLists,
    'isAdult': isAdult,
    'isLicensed': isLicensed,
  };

  static const animeServices = {
    (name: 'Crunchyroll', id: 5),
    (name: 'Hulu', id: 7),
    (name: 'Netflix', id: 10),
    (name: 'YouTube', id: 13),
    (name: 'HIDIVE', id: 20),
    (name: 'Amazon Prime Video', id: 21),
    (name: 'Vimeo', id: 22),
    (name: 'RetroCrush', id: 27),
    (name: 'Adult Swim', id: 28),
    (name: 'Japanese Film Archives', id: 29),
    (name: 'Tubi TV', id: 30),
    (name: 'Crackle', id: 31),
    (name: 'AsianCrush', id: 32),
    (name: 'Midnight Pulp', id: 33),
    (name: 'Bilibili', id: 45),
    (name: 'Disney Plus', id: 118),
    (name: 'Bilibili TV', id: 119),
    (name: 'Tencent Video', id: 121),
    (name: 'iQ', id: 122),
    (name: 'Youku', id: 126),
    (name: 'WeTV', id: 131),
    (name: 'Niconico Video', id: 180),
    (name: 'iQIYI', id: 204),
    (name: 'Star+', id: 210),
    (name: 'Max', id: 211),
    (name: 'Viki', id: 214),
    (name: 'Cineverse', id: 216),
    (name: 'Youku TV', id: 218),
    (name: 'Coolmic', id: 226),
    (name: 'Criterion Channel', id: 230),
    (name: 'Hoopla', id: 239),
    (name: 'Laftel', id: 245),
    (name: 'OceanVeil', id: 249),
    (name: 'Apple TV+', id: 250),
    (name: 'Bandai Channel', id: 251),
    (name: 'Prime Video', id: 261),
    (name: 'Mangamillion', id: 279),
  };

  static const mangaServicesByLanguage = [
    (
      language: 'English',
      services: [
        (name: 'FAKKU', id: 37),
        (name: 'WebComics', id: 41),
        (name: 'MANGA Plus', id: 42),
        (name: 'WEBTOON', id: 43),
        (name: 'Toomics', id: 44),
        (name: 'Lezhin', id: 46),
        (name: 'Tapas', id: 75),
        (name: 'Tappytoon', id: 77),
        (name: 'Manta', id: 80),
        (name: 'Webnovel', id: 86),
        (name: 'MangaToon', id: 103),
        (name: 'J-Novel Club', id: 105),
        (name: 'Lalatoon', id: 113),
        (name: 'TOPTOON', id: 116),
        (name: 'MangaPlaza', id: 128),
        (name: 'VIZ', id: 132),
        (name: 'Omoi', id: 153),
        (name: 'Comikey', id: 157),
        (name: 'INKR', id: 159),
        (name: 'Alpha Manga', id: 163),
        (name: 'Pixiv', id: 166),
        (name: 'Coolmic', id: 169),
        (name: 'Lezhin X', id: 181),
        (name: 'Manga UP!', id: 199),
        (name: 'Irodori Comics', id: 213),
        (name: 'K MANGA', id: 215),
        (name: 'Doujin', id: 246),
        (name: 'Renta!', id: 267),
        (name: 'MANGA MILLION', id: 280),
      ],
    ),
    (
      language: 'Japanese',
      services: [
        (name: 'Mangabox', id: 57),
        (name: 'Kadocomi', id: 58),
        (name: 'Nico Nico Seiga', id: 59),
        (name: 'Pixiv Comic', id: 60),
        (name: 'Comico', id: 62),
        (name: 'Piccoma', id: 63),
        (name: 'Shonen Jump Plus', id: 71),
        (name: 'Pocket Magazine', id: 72),
        (name: 'Sunday Webry', id: 83),
        (name: 'Ganma!', id: 84),
        (name: 'Cycomics', id: 85),
        (name: 'Tonari no Young Jump', id: 87),
        (name: 'Manga Park', id: 88),
        (name: 'Comic Days', id: 89),
        (name: 'Comic Zenon', id: 90),
        (name: 'Manga Library Z', id: 93),
        (name: 'Manga Love', id: 95),
        (name: 'Manga Dokuha', id: 98),
        (name: 'AlphaPolis', id: 99),
        (name: 'Ura Sunday', id: 100),
        (name: 'Comic Essay', id: 102),
        (name: 'Lezhin', id: 108),
        (name: 'Kurage Bunch', id: 110),
        (name: 'Comic Action', id: 111),
        (name: 'Lalatoon', id: 114),
        (name: 'Comic Fuz', id: 138),
        (name: 'MangaToon', id: 139),
        (name: 'Champion Cross', id: 155),
        (name: 'HERO\'S Web', id: 156),
        (name: 'Comic Meteor', id: 158),
        (name: 'Comic Ride', id: 160),
        (name: 'Magcomi', id: 161),
        (name: 'Gangan Online', id: 171),
        (name: 'Comic Trail', id: 172),
        (name: 'Ciao Plus', id: 179),
        (name: 'Toomics', id: 186),
        (name: 'BeLTOON', id: 207),
        (name: 'Yanmanga', id: 220),
        (name: 'Young Animal', id: 222),
        (name: 'Big Comics', id: 223),
        (name: 'Young Champion Web', id: 224),
        (name: 'Manga UP!', id: 229),
        (name: 'Furakomi like!', id: 231),
        (name: 'Rimacomi Plus', id: 232),
        (name: 'Weekly CoroCoro Comic', id: 234),
        (name: 'Shonen Jump', id: 236),
        (name: 'TOPTOON', id: 237),
        (name: 'Manga Mee', id: 240),
        (name: 'Yarawaka Spirits', id: 252),
        (name: 'Gau Gau', id: 253),
        (name: 'Comic Ryu', id: 254),
        (name: 'Asacomi', id: 255),
        (name: 'Ichijin Plus', id: 256),
        (name: 'FEEL web', id: 258),
        (name: 'Takecomic', id: 262),
        (name: 'SORAJIMA TOON', id: 263),
        (name: 'Manga One', id: 268),
        (name: 'Hana to Yume+', id: 270),
      ],
    ),
    (
      language: 'Korean',
      services: [
        (name: 'Lezhin', id: 51),
        (name: 'Toomics', id: 52),
        (name: 'Naver Webtoon', id: 54),
        (name: 'KakaoPage', id: 55),
        (name: 'Bomtoon', id: 56),
        (name: 'Naver Series', id: 134),
        (name: 'TOPTOON', id: 136),
        (name: 'Kakao Webtoon', id: 137),
        (name: 'Anytoon', id: 173),
        (name: 'Mootoon', id: 174),
        (name: 'Onestory', id: 177),
        (name: 'QToon', id: 203),
      ],
    ),
    (
      language: 'Chinese',
      services: [
        (name: 'Tencent Comics', id: 65),
        (name: 'KuaiKan Manhua', id: 66),
        (name: 'Dajiachong Manhua', id: 69),
        (name: 'Manman Manhua', id: 70),
        (name: 'Kai Manhua', id: 94),
        (name: 'MangaToon', id: 104),
        (name: 'Creative Comic Collection', id: 106),
        (name: 'Lalatoon', id: 112),
        (name: 'MKZan', id: 123),
        (name: 'Bilibili', id: 124),
        (name: 'iQIYI', id: 130),
        (name: 'WEBTOON', id: 143),
        (name: 'Zhiyin Manke', id: 150),
        (name: 'Kanmanhua', id: 162),
        (name: 'TOPTOON', id: 164),
        (name: 'Toomics', id: 190),
        (name: 'Toomics', id: 191),
        (name: 'Bomtoon', id: 202),
        (name: 'Dongman Manhua', id: 264),
      ],
    ),
    (
      language: 'Portuguese',
      services: [
        (name: 'Comikey', id: 272),
        (name: 'Toomics', id: 275),
        (name: 'MangaToon', id: 277),
      ],
    ),
    (
      language: 'Thai',
      services: [
        (name: 'MangaToon', id: 141),
        (name: 'WEBTOON', id: 144),
        (name: 'Lezhin', id: 149),
        (name: 'Kakao Webtoon', id: 152),
        (name: 'WeComics', id: 208),
        (name: 'Toomics', id: 248),
      ],
    ),
    (
      language: 'German',
      services: [
        (name: 'WEBTOON', id: 146),
        (name: 'Tappytoon', id: 148),
        (name: 'Toomics', id: 188),
        (name: 'Lezhin', id: 209),
      ],
    ),
    (
      language: 'French',
      services: [
        (name: 'MangaToon', id: 142),
        (name: 'WEBTOON', id: 145),
        (name: 'Tappytoon', id: 147),
        (name: 'Lezhin', id: 151),
        (name: 'Toomics', id: 189),
        (name: 'Mangas.io', id: 198),
        (name: 'ONO', id: 247),
      ],
    ),
    (
      language: 'Spanish',
      services: [
        (name: 'Lezhin', id: 109),
        (name: 'WEBTOON', id: 133),
        (name: 'MangaToon', id: 140),
        (name: 'Toomics', id: 187),
        (name: 'Manta', id: 227),
        (name: 'Pentacomix', id: 276),
      ],
    ),
    (language: 'Indonesian', services: [(name: 'WEBTOON', id: 271), (name: 'MangaToon', id: 278)]),
  ];
}

class DiscoverRecommendationsFilter {
  const DiscoverRecommendationsFilter({this.sort = .newest, this.inLists});

  final RecommendationsSort sort;
  final bool? inLists;

  DiscoverRecommendationsFilter copyWith({RecommendationsSort? sort, (bool?,)? inLists}) =>
      DiscoverRecommendationsFilter(
        sort: sort ?? this.sort,
        inLists: inLists == null ? this.inLists : inLists.$1,
      );
}

enum RecommendationsSort {
  newest('ID_DESC'),
  highestRated('RATING_DESC'),
  lowestRated('RATING');

  const RecommendationsSort(this.value);

  final String value;
}

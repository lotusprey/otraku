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
  }) =>
      DiscoverFilter._(
        type: type ?? this.type,
        search: search ?? this.search,
        mediaFilter: mediaFilter ?? this.mediaFilter,
        hasBirthday: hasBirthday ?? this.hasBirthday,
        reviewsFilter: reviewsFilter ?? this.reviewsFilter,
        recommendationsFilter:
            recommendationsFilter ?? this.recommendationsFilter,
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

    filter.genreIn.addAll(map['genreIn'] ?? const []);
    filter.genreNotIn.addAll(map['genreNotIn'] ?? const []);
    filter.tagIn.addAll(map['tagIn'] ?? const []);
    filter.tagNotIn.addAll(map['tagNotIn'] ?? const []);

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
  }) =>
      DiscoverMediaFilter(sort)
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
        if (ofAnime && animeFormats.isNotEmpty)
          'format_in': animeFormats.map((v) => v.value).toList(),
        if (!ofAnime && mangaFormats.isNotEmpty)
          'format_in': mangaFormats.map((v) => v.value).toList(),
        if (statuses.isNotEmpty)
          'status_in': statuses.map((v) => v.value).toList(),
        if (sources.isNotEmpty) 'sources': sources.map((v) => v.value).toList(),
        if (ofAnime && season != null) 'season': season!.value,
        if (genreIn.isNotEmpty) 'genre_in': genreIn,
        if (genreNotIn.isNotEmpty) 'genre_not_in': genreNotIn,
        if (tagIn.isNotEmpty) 'tag_in': tagIn,
        if (tagNotIn.isNotEmpty) 'tag_not_in': tagNotIn,
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
        'sort': sort.index,
        'season': season?.index,
        'startYearFrom': startYearFrom,
        'startYearTo': startYearTo,
        'country': country?.index,
        'inLists': inLists,
        'isAdult': isAdult,
        'isLicensed': isLicensed,
      };
}

class DiscoverRecommendationsFilter {
  const DiscoverRecommendationsFilter({
    this.sort = RecommendationsSort.recent,
    this.inLists,
  });

  final RecommendationsSort sort;
  final bool? inLists;

  DiscoverRecommendationsFilter copyWith({
    RecommendationsSort? sort,
    (bool?,)? inLists,
  }) =>
      DiscoverRecommendationsFilter(
        sort: sort ?? this.sort,
        inLists: inLists == null ? this.inLists : inLists.$1,
      );
}

enum RecommendationsSort {
  recent('ID_DESC'),
  highestRated('RATING_DESC'),
  lowestRated('RATING');

  const RecommendationsSort(this.value);

  final String value;
}

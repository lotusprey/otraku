import 'package:otraku/feature/filter/filter_collection_model.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/feature/media/media_models.dart';

class DiscoverMediaFilter {
  DiscoverMediaFilter();

  final statuses = <ReleaseStatus>[];
  final animeFormats = <MediaFormat>[];
  final mangaFormats = <MediaFormat>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  final sources = <MediaSource>[];
  MediaSort sort = Persistence().defaultDiscoverSort;
  MediaSeason? season;
  int? startYearFrom;
  int? startYearTo;
  OriginCountry? country;
  bool? inLists;
  bool? isAdult;

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
      isAdult != null;

  DiscoverMediaFilter copy() => DiscoverMediaFilter()
    ..statuses.addAll(statuses)
    ..animeFormats.addAll(animeFormats)
    ..mangaFormats.addAll(mangaFormats)
    ..genreIn.addAll(genreIn)
    ..genreNotIn.addAll(genreNotIn)
    ..tagIn.addAll(tagIn)
    ..tagNotIn.addAll(tagNotIn)
    ..sources.addAll(sources)
    ..sort = sort
    ..season = season
    ..startYearFrom = startYearFrom
    ..startYearTo = startYearTo
    ..country = country
    ..inLists = inLists
    ..isAdult = isAdult;

  static DiscoverMediaFilter fromCollection({
    required CollectionMediaFilter filter,
    required ofAnime,
  }) =>
      DiscoverMediaFilter()
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

  Map<String, dynamic> toMap(bool ofAnime) => {
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
      };
}

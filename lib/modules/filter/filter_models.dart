import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/options.dart';

class CollectionMediaFilter {
  CollectionMediaFilter(bool ofAnime)
      : sort =
            ofAnime ? Options().defaultAnimeSort : Options().defaultMangaSort;

  final statuses = <String>[];
  final formats = <String>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  final tagIdIn = <int>[];
  final tagIdNotIn = <int>[];
  late EntrySort sort;
  int? startYearFrom;
  int? startYearTo;
  OriginCountry? country;

  CollectionMediaFilter copy() => CollectionMediaFilter(true)
    ..statuses.addAll(statuses)
    ..formats.addAll(formats)
    ..genreIn.addAll(genreIn)
    ..genreNotIn.addAll(genreNotIn)
    ..tagIn.addAll(tagIn)
    ..tagNotIn.addAll(tagNotIn)
    ..tagIdIn.addAll(tagIdIn)
    ..tagIdNotIn.addAll(tagIdNotIn)
    ..sort = sort
    ..startYearFrom = startYearFrom
    ..startYearTo = startYearTo
    ..country = country;
}

class DiscoverMediaFilter {
  DiscoverMediaFilter();

  final statuses = <String>[];
  final animeFormats = <String>[];
  final mangaFormats = <String>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  final sources = <String>[];
  MediaSort sort = Options().defaultDiscoverSort;
  MediaSeason? season;
  int? startYearFrom;
  int? startYearTo;
  OriginCountry? country;
  bool? onList;
  bool? isAdult;

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
    ..onList = onList
    ..isAdult = isAdult;

  Map<String, dynamic> toMap(bool ofAnime) => {
        'sort': sort.name,
        if (ofAnime && animeFormats.isNotEmpty) 'format_in': animeFormats,
        if (!ofAnime && mangaFormats.isNotEmpty) 'format_in': mangaFormats,
        if (ofAnime && season != null) 'season': season!.name,
        if (statuses.isNotEmpty) 'status_in': statuses,
        if (genreIn.isNotEmpty) 'genre_in': genreIn,
        if (genreNotIn.isNotEmpty) 'genre_not_in': genreNotIn,
        if (tagIn.isNotEmpty) 'tag_in': tagIn,
        if (tagNotIn.isNotEmpty) 'tag_not_in': tagNotIn,
        if (sources.isNotEmpty) 'sources': sources,
        if (startYearFrom != null) 'startFrom': '${startYearFrom! - 1}9999',
        if (startYearTo != null) 'startTo': '${startYearTo! + 1}0000',
        if (country != null) 'countryOfOrigin': country!.code,
        if (onList != null) 'onList': onList,
        if (isAdult != null) 'isAdult': isAdult,
      };
}

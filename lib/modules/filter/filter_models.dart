import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/media/media_models.dart';

class CollectionMediaFilter {
  CollectionMediaFilter(bool ofAnime)
      : sort = ofAnime
            ? Persistence().defaultAnimeSort
            : Persistence().defaultMangaSort;

  final statuses = <String>[];
  final formats = <MediaFormat>[];
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
  bool? isPrivate;
  bool? hasNotes;

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
    ..country = country
    ..isPrivate = isPrivate
    ..hasNotes = hasNotes;
}

class DiscoverMediaFilter {
  DiscoverMediaFilter();

  final statuses = <MediaStatus>[];
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

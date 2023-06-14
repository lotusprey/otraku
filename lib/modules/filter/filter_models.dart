import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/options.dart';

sealed class MediaFilter<T extends MediaFilter<T>> {
  MediaFilter(this._ofAnime);

  bool _ofAnime;
  bool get ofAnime => _ofAnime;

  T clear();
  T copy();
}

class CollectionMediaFilter extends MediaFilter<CollectionMediaFilter> {
  CollectionMediaFilter(super.ofAnime);

  final statuses = <String>[];
  final formats = <String>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  final tagIdIn = <int>[];
  final tagIdNotIn = <int>[];
  late EntrySort sort =
      _ofAnime ? Options().defaultAnimeSort : Options().defaultMangaSort;
  int? startYearFrom;
  int? startYearTo;
  OriginCountry? country;

  @override
  CollectionMediaFilter clear() => CollectionMediaFilter(_ofAnime);

  @override
  CollectionMediaFilter copy() => CollectionMediaFilter(_ofAnime)
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

class DiscoverMediaFilter extends MediaFilter<DiscoverMediaFilter> {
  DiscoverMediaFilter(super.ofAnime);

  final statuses = <String>[];
  final formats = <String>[];
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

  set ofAnime(bool val) {
    _ofAnime = val;
    formats.clear();
  }

  @override
  DiscoverMediaFilter clear() => DiscoverMediaFilter(_ofAnime);

  @override
  DiscoverMediaFilter copy() => DiscoverMediaFilter(_ofAnime)
    ..statuses.addAll(statuses)
    ..formats.addAll(formats)
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

  Map<String, dynamic> toMap() => {
        'sort': sort.name,
        if (statuses.isNotEmpty) 'status_in': statuses,
        if (formats.isNotEmpty) 'format_in': formats,
        if (genreIn.isNotEmpty) 'genre_in': genreIn,
        if (genreNotIn.isNotEmpty) 'genre_not_in': genreNotIn,
        if (tagIn.isNotEmpty) 'tag_in': tagIn,
        if (tagNotIn.isNotEmpty) 'tag_not_in': tagNotIn,
        if (sources.isNotEmpty) 'sources': sources,
        if (season != null) 'season': season!.name,
        if (startYearFrom != null) 'startFrom': '${startYearFrom! - 1}9999',
        if (startYearTo != null) 'startTo': '${startYearTo! + 1}0000',
        if (country != null) 'countryOfOrigin': country!.code,
        if (onList != null) 'onList': onList,
        if (isAdult != null) 'isAdult': isAdult,
      };
}

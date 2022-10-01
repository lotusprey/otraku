import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/settings.dart';

abstract class ApplicableMediaFilter<T extends ApplicableMediaFilter<T>> {
  ApplicableMediaFilter(this._ofAnime);

  bool _ofAnime;
  bool get ofAnime => _ofAnime;

  /// Creates a copy.
  T copy();

  /// Creates an unconfigured instance.
  T clear();
}

class CollectionFilter extends ApplicableMediaFilter<CollectionFilter> {
  CollectionFilter(super.ofAnime);

  final statuses = <String>[];
  final formats = <String>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  final tagIdIn = <int>[];
  final tagIdNotIn = <int>[];
  late EntrySort sort =
      _ofAnime ? Settings().defaultAnimeSort : Settings().defaultMangaSort;
  String? country;

  @override
  CollectionFilter copy() => CollectionFilter(_ofAnime)
    ..statuses.addAll(statuses)
    ..formats.addAll(formats)
    ..genreIn.addAll(genreIn)
    ..genreNotIn.addAll(genreNotIn)
    ..tagIn.addAll(tagIn)
    ..tagNotIn.addAll(tagNotIn)
    ..tagIdIn.addAll(tagIdIn)
    ..tagIdNotIn.addAll(tagIdNotIn)
    ..sort = sort
    ..country = country;

  @override
  CollectionFilter clear() => CollectionFilter(_ofAnime);
}

class DiscoverFilter extends ApplicableMediaFilter<DiscoverFilter> {
  DiscoverFilter(super.ofAnime);

  final statuses = <String>[];
  final formats = <String>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  MediaSort sort = Settings().defaultDiscoverSort;
  MediaSeason? season;
  String? country;
  bool? onList;

  set ofAnime(bool val) {
    _ofAnime = val;
    formats.clear();
  }

  @override
  DiscoverFilter copy() => DiscoverFilter(_ofAnime)
    ..statuses.addAll(statuses)
    ..formats.addAll(formats)
    ..genreIn.addAll(genreIn)
    ..genreNotIn.addAll(genreNotIn)
    ..tagIn.addAll(tagIn)
    ..tagNotIn.addAll(tagNotIn)
    ..sort = sort
    ..season = season
    ..country = country
    ..onList = onList;

  @override
  DiscoverFilter clear() => DiscoverFilter(_ofAnime);

  Map<String, dynamic> toMap() => {
        'sort': sort.name,
        if (statuses.isNotEmpty) 'status_in': statuses,
        if (formats.isNotEmpty) 'format_in': formats,
        if (genreIn.isNotEmpty) 'genre_in': genreIn,
        if (genreNotIn.isNotEmpty) 'genre_not_in': genreNotIn,
        if (tagIn.isNotEmpty) 'tag_in': tagIn,
        if (tagNotIn.isNotEmpty) 'tag_not_in': tagNotIn,
        if (season != null) 'season': season!.name,
        if (country != null) 'countryOfOrigin': country,
        if (onList != null) 'onList': onList,
      };
}

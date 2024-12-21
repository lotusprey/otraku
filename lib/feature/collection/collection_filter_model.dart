import 'package:otraku/feature/media/media_models.dart';

class CollectionFilter {
  const CollectionFilter._({required this.search, required this.mediaFilter});

  CollectionFilter(EntrySort sort)
      : search = '',
        mediaFilter = CollectionMediaFilter(sort);

  final String search;
  final CollectionMediaFilter mediaFilter;

  CollectionFilter copyWith({
    String? search,
    CollectionMediaFilter? mediaFilter,
  }) =>
      CollectionFilter._(
        search: search ?? this.search,
        mediaFilter: mediaFilter ?? this.mediaFilter,
      );
}

class CollectionMediaFilter {
  CollectionMediaFilter(this.sort);

  final statuses = <ReleaseStatus>[];
  final formats = <MediaFormat>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  EntrySort sort;
  int? startYearFrom;
  int? startYearTo;
  OriginCountry? country;
  bool? isPrivate;
  bool? hasNotes;

  bool get isActive =>
      statuses.isNotEmpty ||
      formats.isNotEmpty ||
      genreIn.isNotEmpty ||
      genreNotIn.isNotEmpty ||
      tagIn.isNotEmpty ||
      tagNotIn.isNotEmpty ||
      startYearFrom != null ||
      startYearTo != null ||
      country != null ||
      isPrivate != null ||
      hasNotes != null;

  CollectionMediaFilter copy() => CollectionMediaFilter(sort)
    ..statuses.addAll(statuses)
    ..formats.addAll(formats)
    ..genreIn.addAll(genreIn)
    ..genreNotIn.addAll(genreNotIn)
    ..tagIn.addAll(tagIn)
    ..tagNotIn.addAll(tagNotIn)
    ..sort = sort
    ..startYearFrom = startYearFrom
    ..startYearTo = startYearTo
    ..country = country
    ..isPrivate = isPrivate
    ..hasNotes = hasNotes;
}

import 'package:otraku/feature/media/media_models.dart';

class CollectionMediaFilter {
  CollectionMediaFilter(this.sort);

  final statuses = <ReleaseStatus>[];
  final formats = <MediaFormat>[];
  final genreIn = <String>[];
  final genreNotIn = <String>[];
  final tagIn = <String>[];
  final tagNotIn = <String>[];
  final tagIdIn = <int>[];
  final tagIdNotIn = <int>[];
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
    ..tagIdIn.addAll(tagIdIn)
    ..tagIdNotIn.addAll(tagIdNotIn)
    ..sort = sort
    ..startYearFrom = startYearFrom
    ..startYearTo = startYearTo
    ..country = country
    ..isPrivate = isPrivate
    ..hasNotes = hasNotes;
}

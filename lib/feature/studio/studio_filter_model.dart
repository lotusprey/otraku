import 'package:otraku/feature/media/media_models.dart';

class StudioFilter {
  const StudioFilter({
    this.sort = MediaSort.startDateDesc,
    this.inLists,
    this.isMain,
  });

  final MediaSort sort;
  final bool? inLists;
  final bool? isMain;

  StudioFilter copyWith({
    MediaSort? sort,
    (bool?,)? inLists,
    (bool?,)? isMain,
  }) =>
      StudioFilter(
        sort: sort ?? this.sort,
        inLists: inLists == null ? this.inLists : inLists.$1,
        isMain: isMain == null ? this.isMain : isMain.$1,
      );
}

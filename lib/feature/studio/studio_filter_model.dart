import 'package:otraku/feature/media/media_models.dart';

class StudioFilter {
  StudioFilter({
    this.sort = MediaSort.startDateDesc,
    this.inLists,
    this.isMain,
  });

  final MediaSort sort;
  final bool? inLists;
  final bool? isMain;

  StudioFilter copyWith({
    MediaSort? sort,
    bool? Function()? inLists,
    bool? Function()? isMain,
  }) =>
      StudioFilter(
        sort: sort ?? this.sort,
        inLists: inLists == null ? this.inLists : inLists(),
        isMain: isMain == null ? this.isMain : isMain(),
      );
}

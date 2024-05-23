import 'package:otraku/feature/media/media_models.dart';

class StaffFilter {
  StaffFilter({
    this.sort = MediaSort.startDateDesc,
    this.ofAnime,
    this.inLists,
  });

  final MediaSort sort;
  final bool? ofAnime;
  final bool? inLists;

  StaffFilter copyWith({
    MediaSort? sort,
    bool? Function()? ofAnime,
    bool? Function()? inLists,
  }) =>
      StaffFilter(
        sort: sort ?? this.sort,
        ofAnime: ofAnime == null ? this.ofAnime : ofAnime(),
        inLists: inLists == null ? this.inLists : inLists(),
      );
}

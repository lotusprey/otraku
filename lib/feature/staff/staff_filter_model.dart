import 'package:otraku/feature/media/media_models.dart';

class StaffFilter {
  const StaffFilter({
    this.sort = MediaSort.startDateDesc,
    this.ofAnime,
    this.inLists,
  });

  final MediaSort sort;
  final bool? ofAnime;
  final bool? inLists;

  StaffFilter copyWith({
    MediaSort? sort,
    (bool?,)? ofAnime,
    (bool?,)? inLists,
  }) =>
      StaffFilter(
        sort: sort ?? this.sort,
        ofAnime: ofAnime == null ? this.ofAnime : ofAnime.$1,
        inLists: inLists == null ? this.inLists : inLists.$1,
      );
}

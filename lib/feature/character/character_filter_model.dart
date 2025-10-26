import 'package:otraku/feature/media/media_models.dart';

class CharacterFilter {
  const CharacterFilter({this.sort = MediaSort.trendingDesc, this.inLists});

  final MediaSort sort;
  final bool? inLists;

  CharacterFilter copyWith({MediaSort? sort, (bool?,)? inLists}) => CharacterFilter(
        sort: sort ?? this.sort,
        inLists: inLists == null ? this.inLists : inLists.$1,
      );
}

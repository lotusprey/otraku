import 'package:otraku/common/tile_item.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/common/pagination.dart';

class StudioItem {
  StudioItem._({required this.id, required this.name});

  factory StudioItem(Map<String, dynamic> map) =>
      StudioItem._(id: map['id'], name: map['name']);

  final int id;
  final String name;
}

class Studio {
  Studio._({
    required this.id,
    required this.name,
    required this.favorites,
    required this.isFavorite,
  });

  factory Studio(Map<String, dynamic> map) => Studio._(
        id: map['id'],
        name: map['name'],
        favorites: map['favourites'] ?? 0,
        isFavorite: map['isFavourite'] ?? false,
      );

  final int id;
  final String name;
  final int favorites;
  bool isFavorite;
}

class StudioState {
  StudioState(this.studio, this.media, this.categories);

  final Studio studio;
  final Pagination<TileItem> media;

  /// If the items in [media] are sorted by date, [categories] will represent
  /// each time category (e.g. "2022") and the index of the first item in
  /// [media] that is contained in this category. The index of the last item is
  /// determined by the starting index of the next category (if there is one).
  /// If the items in [media] aren't sorted by date, [categories] must be empty.
  final Map<String, int> categories;

  StudioState copyWith(Pagination<TileItem> media) =>
      StudioState(studio, media, categories);
}

class StudioFilter {
  StudioFilter({
    this.sort = MediaSort.START_DATE_DESC,
    this.onList,
    this.isMain,
  });

  final MediaSort sort;
  final bool? onList;
  final bool? isMain;

  StudioFilter copyWith({
    MediaSort? sort,
    bool? Function()? onList,
    bool? Function()? isMain,
  }) =>
      StudioFilter(
        sort: sort ?? this.sort,
        onList: onList == null ? this.onList : onList(),
        isMain: isMain == null ? this.isMain : isMain(),
      );
}

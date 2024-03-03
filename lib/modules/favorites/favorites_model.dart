import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/modules/studio/studio_models.dart';

class Favorites {
  const Favorites({
    this.anime = const PagedWithTotal(),
    this.manga = const PagedWithTotal(),
    this.characters = const PagedWithTotal(),
    this.staff = const PagedWithTotal(),
    this.studios = const PagedWithTotal(),
  });

  final PagedWithTotal<TileItem> anime;
  final PagedWithTotal<TileItem> manga;
  final PagedWithTotal<TileItem> characters;
  final PagedWithTotal<TileItem> staff;
  final PagedWithTotal<StudioItem> studios;

  int getCount(FavoritesTab tab) => switch (tab) {
        FavoritesTab.anime => anime.total,
        FavoritesTab.manga => manga.total,
        FavoritesTab.characters => characters.total,
        FavoritesTab.staff => staff.total,
        FavoritesTab.studios => studios.total,
      };
}

enum FavoritesTab {
  anime,
  manga,
  characters,
  staff,
  studios;

  String get title => switch (this) {
        FavoritesTab.anime => 'Favourite Anime',
        FavoritesTab.manga => 'Favourite Manga',
        FavoritesTab.characters => 'Favourite Characters',
        FavoritesTab.staff => 'Favourite Staff',
        FavoritesTab.studios => 'Favourite Studios',
      };
}

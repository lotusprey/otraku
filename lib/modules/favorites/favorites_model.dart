import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/modules/studio/studio_models.dart';

class Favorites {
  const Favorites({
    this.anime = const AsyncValue.loading(),
    this.manga = const AsyncValue.loading(),
    this.characters = const AsyncValue.loading(),
    this.staff = const AsyncValue.loading(),
    this.studios = const AsyncValue.loading(),
  });

  final AsyncValue<PagedWithTotal<TileItem>> anime;
  final AsyncValue<PagedWithTotal<TileItem>> manga;
  final AsyncValue<PagedWithTotal<TileItem>> characters;
  final AsyncValue<PagedWithTotal<TileItem>> staff;
  final AsyncValue<PagedWithTotal<StudioItem>> studios;

  int getCount(FavoritesTab tab) => switch (tab) {
        FavoritesTab.anime => anime.valueOrNull?.total ?? 0,
        FavoritesTab.manga => manga.valueOrNull?.total ?? 0,
        FavoritesTab.characters => characters.valueOrNull?.total ?? 0,
        FavoritesTab.staff => staff.valueOrNull?.total ?? 0,
        FavoritesTab.studios => studios.valueOrNull?.total ?? 0,
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

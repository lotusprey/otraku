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

  int getCount(FavoritesTab tab) {
    switch (tab) {
      case FavoritesTab.anime:
        return anime.valueOrNull?.total ?? 0;
      case FavoritesTab.manga:
        return manga.valueOrNull?.total ?? 0;
      case FavoritesTab.characters:
        return characters.valueOrNull?.total ?? 0;
      case FavoritesTab.staff:
        return staff.valueOrNull?.total ?? 0;
      case FavoritesTab.studios:
        return studios.valueOrNull?.total ?? 0;
    }
  }
}

enum FavoritesTab {
  anime,
  manga,
  characters,
  staff,
  studios;

  String get title {
    switch (this) {
      case FavoritesTab.anime:
        return 'Favourite Anime';
      case FavoritesTab.manga:
        return 'Favourite Manga';
      case FavoritesTab.characters:
        return 'Favourite Characters';
      case FavoritesTab.staff:
        return 'Favourite Staff';
      case FavoritesTab.studios:
        return 'Favourite Studios';
    }
  }
}

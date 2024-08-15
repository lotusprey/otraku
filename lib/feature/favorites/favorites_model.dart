import 'package:otraku/feature/character/character_item_model.dart';
import 'package:otraku/feature/media/media_item_model.dart';
import 'package:otraku/feature/staff/staff_item_model.dart';
import 'package:otraku/feature/studio/studio_item_model.dart';
import 'package:otraku/util/paged.dart';

class Favorites {
  const Favorites({
    this.anime = const PagedWithTotal(),
    this.manga = const PagedWithTotal(),
    this.characters = const PagedWithTotal(),
    this.staff = const PagedWithTotal(),
    this.studios = const PagedWithTotal(),
  });

  final PagedWithTotal<MediaItem> anime;
  final PagedWithTotal<MediaItem> manga;
  final PagedWithTotal<CharacterItem> characters;
  final PagedWithTotal<StaffItem> staff;
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

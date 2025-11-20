import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/paged.dart';

class Favorites {
  const Favorites({
    this.anime = const PagedWithTotal(),
    this.manga = const PagedWithTotal(),
    this.characters = const PagedWithTotal(),
    this.staff = const PagedWithTotal(),
    this.studios = const PagedWithTotal(),
    this.edit,
  });

  final PagedWithTotal<FavoriteItem> anime;
  final PagedWithTotal<FavoriteItem> manga;
  final PagedWithTotal<FavoriteItem> characters;
  final PagedWithTotal<FavoriteItem> staff;
  final PagedWithTotal<FavoriteItem> studios;
  final FavoritesEdit? edit;

  int getCount(FavoritesType type) => switch (type) {
    .anime => anime.total,
    .manga => manga.total,
    .characters => characters.total,
    .staff => staff.total,
    .studios => studios.total,
  };

  Favorites withEdit(FavoritesEdit? edit) => Favorites(
    anime: anime,
    manga: manga,
    characters: characters,
    staff: staff,
    studios: studios,
    edit: edit,
  );
}

class FavoritesEdit {
  const FavoritesEdit(this.editedType, this.oldItems);

  /// The favorites category that is currently being edited.
  final FavoritesType editedType;

  /// The favorite items from the category in their original sorting.
  final List<FavoriteItem> oldItems;
}

class FavoriteItem {
  FavoriteItem._({required this.id, required this.name, required this.imageUrl})
    : isFavorite = true;

  factory FavoriteItem.media(Map<String, dynamic> map, ImageQuality imageQuality) => FavoriteItem._(
    id: map['id'],
    name: map['title']['userPreferred'],
    imageUrl: map['coverImage'][imageQuality.value],
  );

  factory FavoriteItem.character(Map<String, dynamic> map) => FavoriteItem._(
    id: map['id'],
    name: map['name']['userPreferred'],
    imageUrl: map['image']['large'],
  );

  factory FavoriteItem.staff(Map<String, dynamic> map) => FavoriteItem._(
    id: map['id'],
    name: map['name']['userPreferred'],
    imageUrl: map['image']['large'],
  );

  factory FavoriteItem.studio(Map<String, dynamic> map) =>
      FavoriteItem._(id: map['id'], name: map['name'], imageUrl: null);

  final int id;
  final String name;
  final String? imageUrl;
  bool isFavorite;
}

enum FavoritesType {
  anime,
  manga,
  characters,
  staff,
  studios;

  String get title => switch (this) {
    .anime => 'Favourite Anime',
    .manga => 'Favourite Manga',
    .characters => 'Favourite Characters',
    .staff => 'Favourite Staff',
    .studios => 'Favourite Studios',
  };
}

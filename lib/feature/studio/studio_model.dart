import 'package:otraku/model/tile_item.dart';
import 'package:otraku/model/paged.dart';

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
    required this.siteUrl,
    required this.favorites,
    required this.isFavorite,
  });

  factory Studio(Map<String, dynamic> map) => Studio._(
        id: map['id'],
        name: map['name'],
        siteUrl: map['siteUrl'],
        favorites: map['favourites'] ?? 0,
        isFavorite: map['isFavourite'] ?? false,
      );

  final int id;
  final String name;
  final String siteUrl;
  final int favorites;
  bool isFavorite;
}

class StudioMedia {
  const StudioMedia({this.media = const Paged(), this.categories = const {}});

  final Paged<TileItem> media;

  /// If the items in [media] are sorted by date, [categories] will represent
  /// each time category (e.g. "2022") and the index of the first item in
  /// [media] that is contained in this category. The index of the last item is
  /// determined by the starting index of the next category (if there is one).
  /// If the items in [media] aren't sorted by date, [categories] must be empty.
  final Map<String, int> categories;
}

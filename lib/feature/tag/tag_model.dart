import 'dart:collection';

import 'package:otraku/extension/iterable_extension.dart';

class Tag {
  final String name;
  final String desciption;
  final bool isSpoiler;
  final int? rank;

  Tag._({
    required this.name,
    required this.rank,
    required this.desciption,
    required this.isSpoiler,
  });

  factory Tag(Map<String, dynamic> map) => Tag._(
        name: map['name'],
        rank: map['rank'],
        desciption: map['description'] ?? 'No description',
        isSpoiler: map['isMediaSpoiler'] ?? false,
      );
}

/// Stores all tags (genres as treated as tags too).
class TagCollection {
  TagCollection._({
    required this.categories,
    required this.ids,
    required this.names,
    required this.descriptions,
    required this.indexByName,
  });

  factory TagCollection(Map<String, dynamic> map) {
    final categories = [(name: _genreCategoryName, indexes: <int>[])];
    final ids = <int>[];
    final names = <String>[];
    final descriptions = <String>[];
    final indexByName = HashMap<String, int>();

    /// Genres are given negative ids, as
    /// to not get mixed up with normal tags.
    int id = -1;
    for (final g in map['GenreCollection']) {
      categories[0].indexes.add(ids.length);
      ids.add(id);
      names.add(g.toString());
      descriptions.add('');

      indexByName.putIfAbsent(names.last, () => names.length - 1);
      id--;
    }

    for (final t in map['MediaTagCollection']) {
      String categoryName =
          t['category'] != null ? (t['category'] as String).replaceFirst('-', '/') : 'Other';
      if (categoryName.isEmpty) categoryName = 'Other';

      var category = categories.firstWhereOrNull(
        (c) => c.name == categoryName,
      );

      if (category == null) {
        category = (name: categoryName, indexes: []);
        categories.add(category);
      }

      category.indexes.add(ids.length);
      ids.add(t['id']);
      names.add(t['name']);
      descriptions.add(t['description'] ?? '');

      indexByName.putIfAbsent(names.last, () => names.length - 1);
    }

    // Sort categories alphabetically.
    // Genres must be at the front, while the adult category must be last.
    categories.sort((a, b) {
      if (a.name == _genreCategoryName) return -1;
      if (a.name == _adultCategoryName) return 1;
      if (b.name == _genreCategoryName) return 1;
      if (b.name == _adultCategoryName) return -1;
      return a.name.compareTo(b.name);
    });

    return TagCollection._(
      categories: categories,
      ids: ids,
      names: names,
      descriptions: descriptions,
      indexByName: indexByName,
    );
  }

  static const _genreCategoryName = 'Genres';
  static const _adultCategoryName = 'Sexual Content';

  /// Each category has a name and a list of indices for its tags.
  final List<({String name, List<int> indexes})> categories;

  /// Tag data.
  final List<int> ids;
  final List<String> names;
  final List<String> descriptions;

  final HashMap<String, int> indexByName;
}

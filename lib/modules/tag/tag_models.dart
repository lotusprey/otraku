import 'dart:collection';

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
        isSpoiler: (map['isGeneralSpoiler'] ?? false) ||
            (map['isMediaSpoiler'] ?? false),
      );
}

// Stores all tags (genres as treated as tags too).
class TagGroup {
  TagGroup._({
    required this.categoryNames,
    required this.categoryItems,
    required this.ids,
    required this.names,
    required this.descriptions,
    required this.indices,
  });

  factory TagGroup(Map<String, dynamic> map) {
    final categoryNames = <String>['Genres'];
    final categoryItems = <List<int>>[[]];
    final ids = <int>[];
    final names = <String>[];
    final descriptions = <String>[];
    final indices = HashMap<String, int>();

    // Genres are given negative indices, as
    // to not get mixed up with normal tags.
    int id = -1;
    for (final g in map['GenreCollection']) {
      categoryItems[0].add(ids.length);
      ids.add(id);
      names.add(g.toString());
      descriptions.add('');

      indices.putIfAbsent(names.last, () => names.length - 1);
      id--;
    }

    for (final t in map['MediaTagCollection']) {
      String category = t['category'] != null
          ? (t['category'] as String).replaceFirst('-', '/')
          : 'Other';
      if (category.isEmpty) category = 'Other';

      int index = categoryNames.indexOf(category);
      if (index < 0) {
        index = categoryNames.length;
        categoryNames.add(category);
        categoryItems.add([]);
      }
      categoryItems[index].add(ids.length);

      ids.add(t['id']);
      names.add(t['name']);
      descriptions.add(t['description'] ?? '');

      indices.putIfAbsent(t['name'], () => names.length - 1);
    }

    return TagGroup._(
      categoryNames: categoryNames,
      categoryItems: categoryItems,
      ids: ids,
      names: names,
      descriptions: descriptions,
      indices: indices,
    );
  }

  final List<String> categoryNames;
  final List<List<int>> categoryItems;

  // Tag data.
  final List<int> ids;
  final List<String> names;
  final List<String> descriptions;

  /// Associates a name with the corret index
  /// in [ids]/[names]/[descriptions].
  final HashMap<String, int> indices;
}

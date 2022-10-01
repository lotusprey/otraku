import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/convert.dart';

class CharacterItem {
  CharacterItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CharacterItem(Map<String, dynamic> map) => CharacterItem._(
        id: map['id'],
        name: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}

class Character {
  Character._({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.altNames,
    required this.altNamesSpoilers,
    required this.dateOfBirth,
    required this.bloodType,
    required this.gender,
    required this.age,
    required this.favorites,
    required this.isFavorite,
  });

  factory Character(Map<String, dynamic> map) {
    final altNames = List<String>.from(map['name']['alternative'] ?? []);
    if (map['name']['native'] != null) {
      altNames.insert(0, map['name']['native'].toString());
    }

    final altNamesSpoilers = List<String>.from(
      map['name']['alternativeSpoiler'] ?? [],
      growable: false,
    );

    return Character._(
      id: map['id'],
      name: map['name']['userPreferred'] ?? '',
      altNames: altNames,
      altNamesSpoilers: altNamesSpoilers,
      description: map['description'] ?? '',
      imageUrl: map['image']['large'],
      dateOfBirth: Convert.mapToDateStr(map['dateOfBirth']),
      bloodType: map['bloodType'],
      gender: map['gender'],
      age: map['age'],
      favorites: map['favourites'] ?? 0,
      isFavorite: map['isFavourite'] ?? false,
    );
  }

  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> altNames;
  final List<String> altNamesSpoilers;
  final String? dateOfBirth;
  final String? bloodType;
  final String? gender;
  final String? age;
  final int favorites;
  bool isFavorite;
}

class CharacterFilter {
  CharacterFilter({this.sort = MediaSort.TRENDING_DESC, this.onList});

  final MediaSort sort;
  final bool? onList;

  CharacterFilter copyWith({MediaSort? sort, bool? Function()? onList}) =>
      CharacterFilter(
        sort: sort ?? this.sort,
        onList: onList == null ? this.onList : onList(),
      );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';

/// Favorite/Unfavorite character. Returns `true` if successful.
Future<bool> toggleFavoriteCharacter(int characterId) async {
  try {
    await Api.get(GqlMutation.toggleFavorite, {'character': characterId});
    return true;
  } catch (_) {
    return false;
  }
}

final characterProvider = FutureProvider.autoDispose.family(
  (ref, int id) async {
    final data = await Api.get(
      GqlQuery.character,
      {'id': id, 'withMain': true},
    );
    return Character(data['Character']);
  },
);

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
    if (map['name']['native'] != null)
      altNames.insert(0, map['name']['native'].toString());

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

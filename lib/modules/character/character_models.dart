import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/convert.dart';

TileItem characterItem(Map<String, dynamic> map) => TileItem(
      id: map['id'],
      type: DiscoverType.character,
      title: map['name']['userPreferred'],
      imageUrl: map['image']['large'],
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

class CharacterMedia {
  const CharacterMedia({
    this.anime = const AsyncValue.loading(),
    this.manga = const AsyncValue.loading(),
    this.languageToVoiceActors = const {},
    this.language = '',
  });

  final AsyncValue<Paged<Relation>> anime;
  final AsyncValue<Paged<Relation>> manga;

  /// For each language, a list of voice actors
  /// is mapped to the corresponding media's id.
  final Map<String, Map<int, List<Relation>>> languageToVoiceActors;

  /// The currently selected language.
  final String language;

  Iterable<String> get languages => languageToVoiceActors.keys;

  /// Returns the media, in which the character has participated,
  /// along with the voice actors, corresponding to the current [language].
  /// If there are multiple actors, the given media is repeated for each actor.
  List<(Relation, Relation?)> getAnimeAndVoiceActors() {
    final anime = this.anime.valueOrNull?.items;
    if (anime == null || anime.isEmpty) return [];

    final actorsPerMedia = languageToVoiceActors[language];
    if (actorsPerMedia == null) return [for (final a in anime) (a, null)];

    final animeAndVoiceActors = <(Relation, Relation?)>[];
    for (final a in anime) {
      final actors = actorsPerMedia[a.id];
      if (actors == null || actors.isEmpty) {
        animeAndVoiceActors.add((a, null));
        continue;
      }

      for (final va in actors) {
        animeAndVoiceActors.add((a, va));
      }
    }

    return animeAndVoiceActors;
  }
}

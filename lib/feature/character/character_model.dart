import 'package:otraku/model/paged.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/model/tile_item.dart';
import 'package:otraku/util/extensions.dart';
import 'package:otraku/util/markdown.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/settings/settings_model.dart';

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
    required this.siteUrl,
    required this.favorites,
    required this.isFavorite,
  });

  factory Character(Map<String, dynamic> map, PersonNaming personNaming) {
    final names = map['name'];
    final nameSegments = [
      names['first'],
      if (names['middle']?.isNotEmpty ?? false) names['middle'],
      if (names['last']?.isNotEmpty ?? false) names['last'],
    ];

    final fullName = personNaming == PersonNaming.romajiWestern
        ? nameSegments.join(' ')
        : nameSegments.reversed.toList().join(' ');
    final nativeName = names['native'];

    final altNames = List<String>.from(names['alternative'] ?? []);
    final altNamesSpoilers = List<String>.from(
      names['alternativeSpoiler'] ?? [],
      growable: false,
    );

    String name;
    if (nativeName != null) {
      if (personNaming != PersonNaming.native) {
        name = fullName;
        altNames.insert(0, nativeName);
      } else {
        name = nativeName;
        altNames.insert(0, fullName);
      }
    } else {
      name = fullName;
    }

    return Character._(
      id: map['id'],
      name: name,
      altNames: altNames,
      altNamesSpoilers: altNamesSpoilers,
      description: parseMarkdown(map['description'] ?? ''),
      imageUrl: map['image']['large'],
      dateOfBirth: StringUtil.fromFuzzyDate(map['dateOfBirth']),
      bloodType: map['bloodType'],
      gender: map['gender'],
      age: map['age'],
      siteUrl: map['siteUrl'],
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
  final String? siteUrl;
  final int favorites;
  bool isFavorite;
}

class CharacterMedia {
  const CharacterMedia({
    this.anime = const Paged(),
    this.manga = const Paged(),
    this.languageToVoiceActors = const {},
    this.language = '',
  });

  final Paged<Relation> anime;
  final Paged<Relation> manga;

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
    final anime = this.anime.items;
    if (anime.isEmpty) return [];

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

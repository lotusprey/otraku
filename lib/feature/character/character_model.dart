import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/model/paged.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/model/tile_item.dart';
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
    required this.preferredName,
    required this.fullName,
    required this.nativeName,
    required this.altNames,
    required this.altNamesSpoilers,
    required this.imageUrl,
    required this.description,
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

    final preferredName = nativeName != null
        ? personNaming != PersonNaming.native
            ? fullName
            : nativeName
        : fullName;

    return Character._(
      id: map['id'],
      preferredName: preferredName,
      fullName: fullName,
      nativeName: nativeName,
      altNames: altNames,
      altNamesSpoilers: altNamesSpoilers,
      description: parseMarkdown(map['description'] ?? ''),
      imageUrl: map['image']['large'],
      dateOfBirth: StringExtension.fromFuzzyDate(map['dateOfBirth']),
      bloodType: map['bloodType'],
      gender: map['gender'],
      age: map['age'],
      siteUrl: map['siteUrl'],
      favorites: map['favourites'] ?? 0,
      isFavorite: map['isFavourite'] ?? false,
    );
  }

  final int id;
  final String preferredName;
  final String fullName;
  final String? nativeName;
  final List<String> altNames;
  final List<String> altNamesSpoilers;
  final String imageUrl;
  final String description;
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
  Paged<(Relation, Relation?)> assembleAnimeWithVoiceActors() {
    if (anime.items.isEmpty) return const Paged();

    final actorsPerMedia = languageToVoiceActors[language];
    if (actorsPerMedia == null) {
      return Paged(
        items: [for (final a in anime.items) (a, null)],
        hasNext: anime.hasNext,
        next: anime.next,
      );
    }

    final animeAndVoiceActors = <(Relation, Relation?)>[];
    for (final a in anime.items) {
      final actors = actorsPerMedia[a.id];
      if (actors == null || actors.isEmpty) {
        animeAndVoiceActors.add((a, null));
        continue;
      }

      for (final va in actors) {
        animeAndVoiceActors.add((a, va));
      }
    }

    return Paged(
      items: animeAndVoiceActors,
      hasNext: anime.hasNext,
      next: anime.next,
    );
  }
}

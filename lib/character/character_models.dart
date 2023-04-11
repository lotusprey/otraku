import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/common/tile_item.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/convert.dart';

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

  /// Fill [resultingMedia] and [resultingVoiceActors] lists, based on the
  /// currently selected [language]. The lists must end up with equal length
  /// or if an incorrect [language] is selected, [resultingVoiceActors] should
  /// be empty. If there are multiple VAs for a media, add the corresponding
  /// media item in [resultingMedia] enough times to compensate. If there are no
  /// VAs to a media, compensate with one `null` item in [resultingVoiceActors].
  void getAnimeAndVoiceActors(
    List<Relation> resultingMedia,
    List<Relation?> resultingVoiceActors,
  ) {
    final anime = this.anime.valueOrNull?.items;
    if (anime == null || anime.isEmpty) return;

    final actorsPerMedia = languageToVoiceActors[language];
    if (actorsPerMedia == null) {
      resultingMedia.addAll(anime);
      return;
    }

    for (final a in anime) {
      final actors = actorsPerMedia[a.id];
      if (actors == null || actors.isEmpty) {
        resultingMedia.add(a);
        resultingVoiceActors.add(null);
        continue;
      }

      for (final va in actors) {
        resultingMedia.add(a);
        resultingVoiceActors.add(va);
      }
    }
  }
}

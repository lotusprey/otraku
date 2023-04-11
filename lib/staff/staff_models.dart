import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/common/tile_item.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/convert.dart';

TileItem staffItem(Map<String, dynamic> map) => TileItem(
      id: map['id'],
      type: DiscoverType.staff,
      title: map['name']['userPreferred'],
      imageUrl: map['image']['large'],
    );

class Staff {
  Staff._({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.altNames,
    required this.dateOfBirth,
    required this.dateOfDeath,
    required this.bloodType,
    required this.homeTown,
    required this.gender,
    required this.age,
    required this.startYear,
    required this.endYear,
    required this.favorites,
    required this.isFavorite,
  });

  factory Staff(Map<String, dynamic> map) {
    final altNames = List<String>.from(map['name']['alternative'] ?? []);
    if (map['name']['native'] != null) {
      altNames.insert(0, map['name']['native'].toString());
    }

    final yearsActive = map['yearsActive'] as List?;

    return Staff._(
      id: map['id'],
      name: map['name']['userPreferred'] ?? '',
      altNames: altNames,
      imageUrl: map['image']['large'],
      description: map['description'] ?? '',
      dateOfBirth: Convert.mapToDateStr(map['dateOfBirth']),
      dateOfDeath: Convert.mapToDateStr(map['dateOfDeath']),
      bloodType: map['bloodType'],
      homeTown: map['homeTown'],
      gender: map['gender'],
      age: map['age']?.toString(),
      startYear: yearsActive != null && yearsActive.isNotEmpty
          ? yearsActive[0].toString()
          : null,
      endYear: yearsActive != null && yearsActive.length > 1
          ? yearsActive[1].toString()
          : null,
      favorites: map['favourites'] ?? 0,
      isFavorite: map['isFavourite'] ?? false,
    );
  }

  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> altNames;
  final String? dateOfBirth;
  final String? dateOfDeath;
  final String? bloodType;
  final String? homeTown;
  final String? gender;
  final String? age;
  final String? startYear;
  final String? endYear;
  final int favorites;
  bool isFavorite;
}

class StaffFilter {
  StaffFilter({
    this.sort = MediaSort.START_DATE_DESC,
    this.ofAnime,
    this.onList,
  });

  final MediaSort sort;
  final bool? ofAnime;
  final bool? onList;

  StaffFilter copyWith({
    MediaSort? sort,
    bool? Function()? ofAnime,
    bool? Function()? onList,
  }) =>
      StaffFilter(
        sort: sort ?? this.sort,
        ofAnime: ofAnime == null ? this.ofAnime : ofAnime(),
        onList: onList == null ? this.onList : onList(),
      );
}

class StaffRelations {
  const StaffRelations({
    this.characters = const AsyncValue.loading(),
    this.roles = const AsyncValue.loading(),
    this.characterMedia = const [],
  });

  final AsyncValue<Paged<Relation>> characters;
  final AsyncValue<Paged<Relation>> roles;
  final List<Relation> characterMedia;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_constants.dart';

TileItem staffItem(Map<String, dynamic> map) => TileItem(
      id: map['id'],
      type: DiscoverType.Staff,
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
    required this.siteUrl,
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
      dateOfBirth:
          DateTimeUtil.fromFuzzyDate(map['dateOfBirth'])?.formattedDate,
      dateOfDeath:
          DateTimeUtil.fromFuzzyDate(map['dateOfDeath'])?.formattedDate,
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
  final String? dateOfBirth;
  final String? dateOfDeath;
  final String? bloodType;
  final String? homeTown;
  final String? gender;
  final String? age;
  final String? startYear;
  final String? endYear;
  final String? siteUrl;
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
    this.charactersAndMedia = const AsyncValue.loading(),
    this.roles = const AsyncValue.loading(),
  });

  final AsyncValue<Paged<(Relation, Relation)>> charactersAndMedia;
  final AsyncValue<Paged<Relation>> roles;
}

import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/markdown.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/settings/settings_model.dart';

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
    required this.siteUrl,
    required this.favorites,
    required this.isFavorite,
  });

  factory Staff(Map<String, dynamic> map, PersonNaming personNaming) {
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

    final yearsActive = map['yearsActive'] as List?;

    return Staff._(
      id: map['id'],
      name: name,
      altNames: altNames,
      imageUrl: map['image']['large'],
      description: parseMarkdown(map['description'] ?? ''),
      dateOfBirth: StringUtil.fromFuzzyDate(map['dateOfBirth']),
      dateOfDeath: StringUtil.fromFuzzyDate(map['dateOfDeath']),
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

class StaffRelations {
  const StaffRelations({
    this.charactersAndMedia = const Paged(),
    this.roles = const Paged(),
  });

  final Paged<(Relation, Relation)> charactersAndMedia;
  final Paged<Relation> roles;
}

class StaffFilter {
  StaffFilter({
    this.sort = MediaSort.startDateDesc,
    this.ofAnime,
    this.inLists,
  });

  final MediaSort sort;
  final bool? ofAnime;
  final bool? inLists;

  StaffFilter copyWith({
    MediaSort? sort,
    bool? Function()? ofAnime,
    bool? Function()? inLists,
  }) =>
      StaffFilter(
        sort: sort ?? this.sort,
        ofAnime: ofAnime == null ? this.ofAnime : ofAnime(),
        inLists: inLists == null ? this.inLists : inLists(),
      );
}

import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/util/markdown.dart';
import 'package:otraku/feature/settings/settings_model.dart';
import 'package:otraku/util/tile_modelable.dart';

class Staff {
  Staff._({
    required this.id,
    required this.preferredName,
    required this.fullName,
    required this.nativeName,
    required this.altNames,
    required this.imageUrl,
    required this.description,
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

    final preferredName = nativeName != null
        ? personNaming != PersonNaming.native
            ? fullName
            : nativeName
        : fullName;

    final yearsActive = map['yearsActive'] as List?;

    return Staff._(
      id: map['id'],
      preferredName: preferredName,
      fullName: fullName,
      nativeName: nativeName,
      altNames: altNames,
      imageUrl: map['image']['large'],
      description: parseMarkdown(map['description'] ?? ''),
      dateOfBirth: StringExtension.fromFuzzyDate(map['dateOfBirth']),
      dateOfDeath: StringExtension.fromFuzzyDate(map['dateOfDeath']),
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
  final String preferredName;
  final String fullName;
  final String? nativeName;
  final List<String> altNames;
  final String imageUrl;
  final String description;
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

  final Paged<(StaffRelatedItem, StaffRelatedItem)> charactersAndMedia;
  final Paged<StaffRelatedItem> roles;
}

class StaffRelatedItem implements TileModelable {
  const StaffRelatedItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.role,
  });

  factory StaffRelatedItem.media(
    Map<String, dynamic> map,
    String? role,
    ImageQuality imageQuality,
  ) =>
      StaffRelatedItem._(
        id: map['id'],
        name: map['title']['userPreferred'],
        imageUrl: map['coverImage'][imageQuality.value],
        role: role,
      );

  factory StaffRelatedItem.character(Map<String, dynamic> map, String? role) =>
      StaffRelatedItem._(
        id: map['id'],
        name: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
        role: role,
      );

  final int id;
  final String name;
  final String imageUrl;
  final String? role;

  @override
  int get tileId => id;

  @override
  String get tileTitle => name;

  @override
  String? get tileSubtitle => role;

  @override
  String get tileImageUrl => imageUrl;
}

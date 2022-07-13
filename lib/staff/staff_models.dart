import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/utils/convert.dart';

class StaffItem {
  StaffItem._({required this.id, required this.name, required this.imageUrl});

  factory StaffItem(Map<String, dynamic> map) => StaffItem._(
        id: map['id'],
        name: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}

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
    if (map['name']['native'] != null)
      altNames.insert(0, map['name']['native'].toString());

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
      startYear: yearsActive != null && yearsActive.length > 0
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
  StaffFilter({this.sort = MediaSort.START_DATE_DESC, this.onList});

  final MediaSort sort;
  final bool? onList;

  StaffFilter copyWith({MediaSort? sort, bool? Function()? onList}) =>
      StaffFilter(
        sort: sort ?? this.sort,
        onList: onList == null ? this.onList : onList(),
      );
}

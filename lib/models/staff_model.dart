class StaffModel {
  final int id;
  final String name;
  final List<String> altNames;
  final String description;
  final String? imageUrl;
  final String? language;
  final List<String> primaryOccupations;
  final String? gender;
  final String? homeTown;
  final int? age;
  final int? startYear;
  final int? endYear;
  final int favourites;
  final bool isFavouriteBlocked;
  bool isFavourite;

  StaffModel._({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.language,
    required this.primaryOccupations,
    required this.gender,
    required this.homeTown,
    required this.age,
    required this.startYear,
    required this.endYear,
    this.altNames = const [],
    this.favourites = 0,
    this.isFavourite = false,
    this.isFavouriteBlocked = false,
  });

  factory StaffModel(Map<String, dynamic> map) {
    final yearsActive = List<int>.from(
      map['yearsActive'] ?? [],
      growable: false,
    );

    final alts = List<String>.from(map['name']['alternative'] ?? []);
    if (map['name']['native'] != null)
      alts.insert(0, map['name']['native'].toString());

    final occupations = List<String>.from(
      map['primaryOccupations'] ?? [],
      growable: false,
    );

    return StaffModel._(
      id: map['id'],
      name: map['name']['userPreferred'] ?? '',
      altNames: alts,
      description: map['description'] ?? '',
      imageUrl: map['image']['large'],
      language: map['languageV2'],
      primaryOccupations: occupations,
      gender: map['gender'],
      homeTown: map['homeTown'],
      age: map['age'],
      startYear: yearsActive.length > 0 ? yearsActive[0] : null,
      endYear: yearsActive.length > 1 ? yearsActive[1] : null,
      favourites: map['favourites'] ?? 0,
      isFavourite: map['isFavourite'] ?? false,
      isFavouriteBlocked: map['isFavouriteBlocked'] ?? false,
    );
  }
}

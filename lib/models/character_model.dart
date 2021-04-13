class CharacterModel {
  final int id;
  final String firstName;
  final String middleName;
  final String lastName;
  final List<String> altNames;
  final List<String> altNamesSpoilers;
  final String description;
  final String? imageUrl;
  final String? gender;
  final String? age;
  final int favourites;
  final bool isFavouriteBlocked;
  bool isFavourite;

  CharacterModel._({
    required this.id,
    required this.imageUrl,
    required this.gender,
    required this.age,
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.description = '',
    this.altNames = const [],
    this.altNamesSpoilers = const [],
    this.favourites = 0,
    this.isFavourite = false,
    this.isFavouriteBlocked = false,
  });

  factory CharacterModel(Map<String, dynamic> map) {
    final alts = map['name']['alternative'] != null
        ? (map['name']['alternative'] as List<dynamic>).cast<String>()
        : <String>[];
    final altsSpoilers = map['name']['alternativeSpoiler'] != null
        ? (map['name']['alternativeSpoiler'] as List<dynamic>).cast<String>()
        : <String>[];
    if (map['name']['native'] != null)
      alts.insert(0, map['name']['native'].toString());

    return CharacterModel._(
      id: map['id'],
      firstName: map['name']['first'] ?? '',
      middleName: map['name']['middle'] ?? '',
      lastName: map['name']['last'] ?? '',
      altNames: alts,
      altNamesSpoilers: altsSpoilers,
      imageUrl: map['image']['large'],
      gender: map['gender'],
      age: map['age'],
      description: map['description'] ?? '',
      favourites: map['favourites'] ?? 0,
      isFavourite: map['isFavourite'] ?? false,
      isFavouriteBlocked: map['isFavouriteBlocked'] ?? false,
    );
  }
}

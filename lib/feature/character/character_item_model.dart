class CharacterItem {
  const CharacterItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CharacterItem(Map<String, dynamic> map) => CharacterItem._(
        id: map['id'],
        name: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}

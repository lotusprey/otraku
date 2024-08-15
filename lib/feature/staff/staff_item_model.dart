class StaffItem {
  const StaffItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory StaffItem(Map<String, dynamic> map) => StaffItem._(
        id: map['id'],
        name: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}

class UserItem {
  const UserItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory UserItem(Map<String, dynamic> map) => UserItem._(
        id: map['id'],
        name: map['name'],
        imageUrl: map['avatar']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}

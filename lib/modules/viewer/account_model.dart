class Account {
  const Account({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.expiration,
  });

  factory Account.fromMap(Map<String, dynamic> map) => Account(
        id: map['id'],
        name: map['name'],
        avatarUrl: map['avatarUrl'],
        expiration: map['expiration'],
      );

  final int id;
  final String name;
  final String avatarUrl;
  final DateTime expiration;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'expiration': expiration,
      };
}

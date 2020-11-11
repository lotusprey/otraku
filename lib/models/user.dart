class User {
  final int id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  final bool isMe;

  User({
    this.id,
    this.name,
    this.description,
    this.avatar,
    this.banner,
    this.isMe = false,
  });
}

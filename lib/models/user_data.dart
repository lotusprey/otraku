class UserData {
  final int id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  bool _following;
  final bool follower;
  final bool blocked;
  final bool isMe;

  UserData._({
    this.id,
    this.name,
    this.description,
    this.avatar,
    this.banner,
    amFollowing,
    this.follower,
    this.blocked,
    this.isMe = false,
  }) {
    _following = amFollowing;
  }

  factory UserData(Map<String, dynamic> map, bool me) => UserData._(
        id: map['id'],
        name: map['name'],
        description: map['about'],
        avatar: map['avatar']['large'],
        banner: map['bannerImage'],
        amFollowing: map['isFollowing'],
        follower: map['isFollower'],
        blocked: map['isBlocked'],
        isMe: me,
      );

  bool get following => _following;

  void toggleFollow(Map<String, dynamic> map) =>
      _following = map['isFollowing'];
}

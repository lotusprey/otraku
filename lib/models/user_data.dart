class UserData {
  final int id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  final bool following;
  final bool follower;
  final bool blocked;
  final bool isMe;

  UserData._({
    this.id,
    this.name,
    this.description,
    this.avatar,
    this.banner,
    this.following,
    this.follower,
    this.blocked,
    this.isMe = false,
  });

  factory UserData(Map<String, dynamic> map, bool me) => UserData._(
        id: map['id'],
        name: map['name'],
        description: map['about'],
        avatar: map['avatar']['large'],
        banner: map['bannerImage'],
        following: map['isFollowing'],
        follower: map['isFollower'],
        blocked: map['isBlocked'],
        isMe: me,
      );
}

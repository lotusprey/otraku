class UserModel {
  final int id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  bool _following;
  final bool follower;
  final bool blocked;
  final String donatorBadge;
  final String moderatorStatus;
  final bool isMe;

  UserModel._({
    this.id,
    this.name,
    this.description,
    this.avatar,
    this.banner,
    followed,
    this.follower,
    this.blocked,
    this.donatorBadge,
    this.moderatorStatus,
    this.isMe = false,
  }) {
    _following = followed;
  }

  factory UserModel(final Map<String, dynamic> map, bool me) => UserModel._(
        id: map['id'],
        name: map['name'],
        description: map['about'],
        avatar: map['avatar']['large'],
        banner: map['bannerImage'],
        followed: map['isFollowing'],
        follower: map['isFollower'],
        blocked: map['isBlocked'],
        donatorBadge: map['donatorBadge'],
        moderatorStatus: map['moderatorStatus'],
        isMe: me,
      );

  bool get following => _following;

  void toggleFollow(final Map<String, dynamic> map) =>
      _following = map['isFollowing'];
}

import 'package:otraku/modules/statistics/user_statistics.dart';
import 'package:otraku/common/utils/convert.dart';

class UserItem {
  UserItem._({required this.id, required this.name, required this.imageUrl});

  factory UserItem(Map<String, dynamic> map) => UserItem._(
        id: map['id'],
        name: map['name'],
        imageUrl: map['avatar']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}

class User {
  User._({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.bannerUrl,
    required this.siteUrl,
    required this.isFollowed,
    required this.isFollower,
    required this.isBlocked,
    required this.donatorTier,
    required this.donatorBadge,
    required this.modRoles,
    required this.animeStats,
    required this.mangaStats,
  });

  factory User(Map<String, dynamic> map) => User._(
        id: map['id'],
        name: map['name'],
        description: map['about'] ?? '',
        imageUrl: map['avatar']['large'],
        bannerUrl: map['bannerImage'],
        siteUrl: map['siteUrl'],
        isFollowed: map['isFollowing'] ?? false,
        isFollower: map['isFollower'] ?? false,
        isBlocked: map['isBlocked'] ?? false,
        donatorTier: map['donatorTier'] ?? 0,
        donatorBadge: map['donatorBadge'] ?? '',
        modRoles: List<String>.from(
          map['moderatorRoles']?.map((r) => '${Convert.clarifyEnum(r)!} Mod') ??
              [],
          growable: false,
        ),
        animeStats: UserStatistics(map['statistics']['anime'], true),
        mangaStats: UserStatistics(map['statistics']['manga'], false),
      );

  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String? bannerUrl;
  final String? siteUrl;
  bool isFollowed;
  final bool isFollower;
  final bool isBlocked;
  final int donatorTier;
  final String donatorBadge;
  final List<String> modRoles;
  final UserStatistics animeStats;
  final UserStatistics mangaStats;
}
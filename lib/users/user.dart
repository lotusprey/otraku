import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/statistics/user_statistics.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

/// Follow/Unfollow user.
Future<bool> toggleFollow(int userId) async {
  try {
    await Api.get(GqlMutation.toggleFollow, {'userId': userId});
    return true;
  } catch (_) {
    return false;
  }
}

final userProvider = FutureProvider.autoDispose.family<User, int>(
  (ref, userId) async {
    if (userId == Settings().id) ref.keepAlive();

    final data = await Api.get(GqlQuery.user, {'userId': userId});
    return User(data['User']);
  },
);

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
        description: map['about'],
        imageUrl: map['avatar']['large'],
        bannerUrl: map['bannerImage'],
        siteUrl: map['siteUrl'],
        isFollowed: map['isFollowing'] ?? false,
        isFollower: map['isFollower'] ?? false,
        isBlocked: map['isBlocked'] ?? false,
        donatorTier: map['donatorTier'] ?? 0,
        donatorBadge: map['donatorBadge'] ?? '',
        modRoles: List<String>.from(
          map['moderatorRoles']?.map((r) => Convert.clarifyEnum(r)) ?? [],
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

import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/models/page_model.dart';

class UserModel {
  static const ANIME_FAV = 0;
  static const MANGA_FAV = 1;
  static const CHARACTER_FAV = 2;
  static const STAFF_FAV = 3;
  static const STUDIO_FAV = 4;

  final int? id;
  final String? name;
  final String? description;
  final String? avatar;
  final String? banner;
  bool isFollowing;
  final bool isFollower;
  final bool blocked;
  final int? donatorTier;
  final String? donatorBadge;
  final String? moderatorStatus;
  final bool isMe;
  final following = PageModel<BrowseResultModel>();
  final followers = PageModel<BrowseResultModel>();
  final activities = PageModel<ActivityModel>();
  final favourites = [
    PageModel<BrowseResultModel>(),
    PageModel<BrowseResultModel>(),
    PageModel<BrowseResultModel>(),
    PageModel<BrowseResultModel>(),
    PageModel<BrowseResultModel>(),
  ];

  UserModel._({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.banner,
    required this.donatorTier,
    required this.donatorBadge,
    required this.moderatorStatus,
    this.blocked = false,
    this.isFollower = false,
    this.isFollowing = false,
    this.isMe = false,
  });

  factory UserModel(final Map<String, dynamic> map, bool me) => UserModel._(
        id: map['id'],
        name: map['name'],
        description: map['about'],
        avatar: map['avatar']['large'],
        banner: map['bannerImage'],
        isFollowing: map['isFollowing'] ?? false,
        isFollower: map['isFollower'] ?? false,
        blocked: map['isBlocked'] ?? false,
        donatorTier: map['donatorTier'],
        donatorBadge: map['donatorBadge'],
        moderatorStatus: map['moderatorStatus'],
        isMe: me,
      );

  void toggleFollow(final Map<String, dynamic> map) =>
      isFollowing = map['isFollowing'] ?? false;

  void addFavs(final int? index, final Map<String, dynamic>? map) {
    final items = <BrowseResultModel>[];
    if (index == null || index == ANIME_FAV) {
      for (final a in map!['anime']['nodes'])
        items.add(BrowseResultModel.anime(a));
      favourites[ANIME_FAV].append(
        items,
        map['anime']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == MANGA_FAV) {
      items.clear();
      for (final m in map!['manga']['nodes'])
        items.add(BrowseResultModel.manga(m));
      favourites[MANGA_FAV].append(
        items,
        map['manga']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == CHARACTER_FAV) {
      items.clear();
      for (final c in map!['characters']['nodes'])
        items.add(BrowseResultModel.character(c));
      favourites[CHARACTER_FAV].append(
        items,
        map['characters']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == STAFF_FAV) {
      items.clear();
      for (final s in map!['staff']['nodes'])
        items.add(BrowseResultModel.staff(s));
      favourites[STAFF_FAV].append(
        items,
        map['staff']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == STUDIO_FAV) {
      items.clear();
      for (final s in map!['studios']['nodes'])
        items.add(BrowseResultModel.studio(s));
      favourites[STUDIO_FAV].append(
        items,
        map['studios']['pageInfo']['hasNextPage'],
      );
    }
  }
}

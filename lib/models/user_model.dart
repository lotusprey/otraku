import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/statistics_model.dart';
import 'package:otraku/utils/convert.dart';

class UserModel {
  static const ANIME_FAV = 0;
  static const MANGA_FAV = 1;
  static const CHARACTER_FAV = 2;
  static const STAFF_FAV = 3;
  static const STUDIO_FAV = 4;

  final int? id;
  final String name;
  final String description;
  final String? avatar;
  final String? banner;
  bool isFollowing;
  final bool isFollower;
  final bool blocked;
  final String? siteUrl;
  final int donatorTier;
  final String donatorBadge;
  final List<String> modRoles;
  final bool isMe;
  final StatisticsModel animeStats;
  final StatisticsModel mangaStats;
  final following = PageModel<ExplorableModel>();
  final followers = PageModel<ExplorableModel>();
  final reviews = PageModel<ExplorableModel>();
  final favourites = [
    PageModel<ExplorableModel>(),
    PageModel<ExplorableModel>(),
    PageModel<ExplorableModel>(),
    PageModel<ExplorableModel>(),
    PageModel<ExplorableModel>(),
  ];

  UserModel._({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.banner,
    required this.siteUrl,
    required this.donatorTier,
    required this.donatorBadge,
    required this.modRoles,
    required this.animeStats,
    required this.mangaStats,
    this.blocked = false,
    this.isFollower = false,
    this.isFollowing = false,
    this.isMe = false,
  });

  factory UserModel(final Map<String, dynamic> map, bool me) => UserModel._(
        id: map['id'],
        name: map['name'] ?? '',
        description: map['about'] ?? '',
        avatar: map['avatar']['large'],
        banner: map['bannerImage'],
        isFollowing: map['isFollowing'] ?? false,
        isFollower: map['isFollower'] ?? false,
        siteUrl: map['siteUrl'],
        blocked: map['isBlocked'] ?? false,
        donatorTier: map['donatorTier'] ?? 0,
        donatorBadge: map['donatorBadge'] ?? '',
        modRoles: List<String>.from(
          map['moderatorRoles']?.map((r) => Convert.clarifyEnum(r)) ?? [],
        ),
        animeStats: StatisticsModel(map['statistics']['anime']),
        mangaStats: StatisticsModel(map['statistics']['manga']),
        isMe: me,
      );

  void toggleFollow(final Map<String, dynamic> map) =>
      isFollowing = map['isFollowing'] ?? false;

  void addFavs(final int? index, final Map<String, dynamic>? map) {
    final items = <ExplorableModel>[];
    if (index == null || index == ANIME_FAV) {
      for (final a in map!['anime']['nodes'])
        items.add(ExplorableModel.anime(a));
      favourites[ANIME_FAV].append(
        items,
        map['anime']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == MANGA_FAV) {
      items.clear();
      for (final m in map!['manga']['nodes'])
        items.add(ExplorableModel.manga(m));
      favourites[MANGA_FAV].append(
        items,
        map['manga']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == CHARACTER_FAV) {
      items.clear();
      for (final c in map!['characters']['nodes'])
        items.add(ExplorableModel.character(c));
      favourites[CHARACTER_FAV].append(
        items,
        map['characters']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == STAFF_FAV) {
      items.clear();
      for (final s in map!['staff']['nodes'])
        items.add(ExplorableModel.staff(s));
      favourites[STAFF_FAV].append(
        items,
        map['staff']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == STUDIO_FAV) {
      items.clear();
      for (final s in map!['studios']['nodes'])
        items.add(ExplorableModel.studio(s));
      favourites[STUDIO_FAV].append(
        items,
        map['studios']['pageInfo']['hasNextPage'],
      );
    }
  }
}

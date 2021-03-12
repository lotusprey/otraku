import 'package:flutter/foundation.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/models/page_model.dart';

class UserModel {
  static const ANIME_FAV = 0;
  static const MANGA_FAV = 1;
  static const CHARACTER_FAV = 2;
  static const STAFF_FAV = 3;
  static const STUDIO_FAV = 4;

  final int id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  bool _following;
  final bool follower;
  final bool blocked;
  final int donatorTier;
  final String donatorBadge;
  final String moderatorStatus;
  final bool isMe;
  final _favourites = [
    PageModel<BrowseResultModel>([], true, 1),
    PageModel<BrowseResultModel>([], true, 1),
    PageModel<BrowseResultModel>([], true, 1),
    PageModel<BrowseResultModel>([], true, 1),
    PageModel<BrowseResultModel>([], true, 1),
  ];

  UserModel._({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.avatar,
    @required this.banner,
    @required followed,
    @required this.follower,
    @required this.blocked,
    @required this.donatorTier,
    @required this.donatorBadge,
    @required this.moderatorStatus,
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
        donatorTier: map['donatorTier'],
        donatorBadge: map['donatorBadge'],
        moderatorStatus: map['moderatorStatus'],
        isMe: me,
      );

  PageModel favourites(final int index) => _favourites[index];
  bool get following => _following;

  void toggleFollow(final Map<String, dynamic> map) =>
      _following = map['isFollowing'];

  void addFavs(final int index, final Map<String, dynamic> map) {
    final List<BrowseResultModel> items = [];
    if (index == null || index == ANIME_FAV) {
      for (final a in map['anime']['nodes'])
        items.add(BrowseResultModel.anime(a));
      _favourites[ANIME_FAV].append(
        items,
        map['anime']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == MANGA_FAV) {
      items.clear();
      for (final m in map['manga']['nodes'])
        items.add(BrowseResultModel.manga(m));
      _favourites[MANGA_FAV].append(
        items,
        map['manga']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == CHARACTER_FAV) {
      items.clear();
      for (final c in map['characters']['nodes'])
        items.add(BrowseResultModel.character(c));
      _favourites[CHARACTER_FAV].append(
        items,
        map['characters']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == STAFF_FAV) {
      items.clear();
      for (final s in map['staff']['nodes'])
        items.add(BrowseResultModel.staff(s));
      _favourites[STAFF_FAV].append(
        items,
        map['staff']['pageInfo']['hasNextPage'],
      );
    }
    if (index == null || index == STUDIO_FAV) {
      items.clear();
      for (final s in map['studios']['nodes'])
        items.add(BrowseResultModel.studio(s));
      _favourites[STUDIO_FAV].append(
        items,
        map['studios']['pageInfo']['hasNextPage'],
      );
    }
  }
}

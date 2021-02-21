import 'package:otraku/enums/browsable.dart';
import 'package:otraku/models/browse_result_model.dart';
import 'package:otraku/models/loadable_list.dart';

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
  final String donatorBadge;
  final String moderatorStatus;
  final bool isMe;
  final _favourites = [
    LoadableList<BrowseResultModel>([], true, 1),
    LoadableList<BrowseResultModel>([], true, 1),
    LoadableList<BrowseResultModel>([], true, 1),
    LoadableList<BrowseResultModel>([], true, 1),
    LoadableList<BrowseResultModel>([], true, 1),
  ];

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

  LoadableList favourites(final int index) => _favourites[index];
  bool get following => _following;

  void toggleFollow(final Map<String, dynamic> map) =>
      _following = map['isFollowing'];

  void addFavs(final int index, final Map<String, dynamic> map) {
    final List<BrowseResultModel> items = [];
    if (index == null || index == ANIME_FAV) {
      for (final node in map['anime']['nodes'])
        items.add(BrowseResultModel(
          id: node['id'],
          text1: node['title']['userPreferred'],
          imageUrl: node['coverImage']['large'],
          browsable: Browsable.anime,
        ));
      _favourites[ANIME_FAV]
          .append(items, map['anime']['pageInfo']['hasNextPage']);
    }
    if (index == null || index == MANGA_FAV) {
      items.clear();
      for (final node in map['manga']['nodes'])
        items.add(BrowseResultModel(
          id: node['id'],
          text1: node['title']['userPreferred'],
          imageUrl: node['coverImage']['large'],
          browsable: Browsable.manga,
        ));
      _favourites[MANGA_FAV]
          .append(items, map['manga']['pageInfo']['hasNextPage']);
    }
    if (index == null || index == CHARACTER_FAV) {
      items.clear();
      for (final node in map['characters']['nodes'])
        items.add(BrowseResultModel(
          id: node['id'],
          text1: node['name']['full'],
          imageUrl: node['image']['large'],
          browsable: Browsable.character,
        ));
      _favourites[CHARACTER_FAV]
          .append(items, map['characters']['pageInfo']['hasNextPage']);
    }
    if (index == null || index == STAFF_FAV) {
      items.clear();
      for (final node in map['staff']['nodes'])
        items.add(BrowseResultModel(
          id: node['id'],
          text1: node['name']['full'],
          imageUrl: node['image']['large'],
          browsable: Browsable.staff,
        ));
      _favourites[STAFF_FAV]
          .append(items, map['staff']['pageInfo']['hasNextPage']);
    }
    if (index == null || index == STUDIO_FAV) {
      items.clear();
      for (final node in map['studios']['nodes'])
        items.add(BrowseResultModel(
          id: node['id'],
          text1: node['name'],
          browsable: Browsable.studio,
        ));
      _favourites[STUDIO_FAV]
          .append(items, map['studios']['pageInfo']['hasNextPage']);
    }
  }
}

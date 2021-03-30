import 'package:get/get.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/user_model.dart';

class User extends GetxController {
  static const _userQuery = r'''
      query User($id: Int, $withMain: Boolean = false, $withAnime: Boolean = false, $withManga: Boolean = false, 
          $withCharacters: Boolean = false, $withStaff: Boolean = false, $withStudios: Boolean = false,
          $favsPage: Int = 1) {
        User(id: $id) {
          ...main @include(if: $withMain)
          favourites {
            anime(page: $favsPage) @include(if: $withAnime) {...media}
            manga(page: $favsPage) @include(if: $withManga) {...media}
            characters(page: $favsPage) @include(if: $withCharacters) {...character}
            staff(page: $favsPage) @include(if: $withStaff) {...staff}
            studios(page: $favsPage) @include(if: $withStudios) {...studio}
          }
        }
      }
      fragment main on User {
        id
        name
        about(asHtml: true)
        avatar {large}
        bannerImage
        isFollowing
        isFollower
        isBlocked
        donatorTier
        donatorBadge
        moderatorStatus
      }
      fragment media on MediaConnection {
        pageInfo {hasNextPage} nodes {id title {userPreferred} coverImage {large}}
      }
      fragment character on CharacterConnection {
        pageInfo {hasNextPage} nodes {id name {full} image {large}}
      }
      fragment staff on StaffConnection {
        pageInfo {hasNextPage} nodes {id name {full} image {large}}
      }
      fragment studio on StudioConnection {pageInfo {hasNextPage} nodes {id name}}
    ''';

  static const _activitiesQuery = r'''
    query Activities($id: Int, $page: Int = 1) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(userId: $id, sort: ID_DESC) {
          ... on TextActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            createdAt
            user {id name avatar {large}}
            text(asHtml: true)
          }
          ... on ListActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            createdAt
            user {id name avatar {large}}
            media {id type title{userPreferred} coverImage{large} format}
            progress
            status
          }
          ... on MessageActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            createdAt
            recipient {id name avatar {large}}
            messenger {id name avatar {large}}
            message(asHtml: true)
          }
        }
      }
    }
  ''';

  static const _toggleFollow =
      r'''mutation FollowUser($id: Int) {ToggleFollow(userId: $id) {isFollowing}}''';

  final int _id;
  User(this._id);

  UserModel? _model;
  int _favsIndex = UserModel.ANIME_FAV;
  bool _loading = true;

  UserModel? get model => _model;
  List<BrowseResultModel> get favourites =>
      _model!.favourites[_favsIndex].items;
  List<ActivityModel> get activities => _model!.activities.items;
  bool get loading => _loading;
  int get favsIndex => _favsIndex;
  String get favPageName {
    if (_favsIndex == UserModel.ANIME_FAV) return 'Anime';
    if (_favsIndex == UserModel.MANGA_FAV) return 'Manga';
    if (_favsIndex == UserModel.CHARACTER_FAV) return 'Characters';
    if (_favsIndex == UserModel.STAFF_FAV) return 'Staff';
    return 'Studios';
  }

  set favsIndex(int index) {
    _favsIndex = index;
    update();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    final data = await Client.request(
      _userQuery,
      {
        'id': _id,
        'withMain': true,
        'withAnime': true,
        'withManga': true,
        'withCharacters': true,
        'withStaff': true,
        'withStudios': true,
      },
      popOnErr: _id != Client.viewerId,
    );
    if (data == null) return;

    _model = UserModel(data['User'], _id == Client.viewerId);
    _model!.addFavs(null, data['User']['favourites']);
    _loading = false;
    update();
  }

  Future<void> fetchFavourites() async {
    if (_loading || !_model!.favourites[_favsIndex].hasNextPage) return;
    _loading = true;

    final data = await Client.request(_userQuery, {
      'id': _id,
      'withAnime': _favsIndex == UserModel.ANIME_FAV,
      'withManga': _favsIndex == UserModel.MANGA_FAV,
      'withCharacters': _favsIndex == UserModel.CHARACTER_FAV,
      'withStaff': _favsIndex == UserModel.STAFF_FAV,
      'withStudios': _favsIndex == UserModel.STUDIO_FAV,
      'favsPage': _model!.favourites[_favsIndex].nextPage,
    });
    if (data == null) return;

    _model!.addFavs(_favsIndex, data['User']['favourites']);
    _loading = false;
    update();
  }

  Future<void> fetchActivities() async {
    if (_loading || !_model!.activities.hasNextPage) return;
    _loading = true;

    final data = await Client.request(_activitiesQuery, {
      'id': _id,
      'page': _model!.activities.nextPage,
    });
    if (data == null) return;

    final List<ActivityModel> al = [];
    for (final a in data['Page']['activities']) {
      final m = ActivityModel(a);
      if (m.valid) al.add(m);
    }
    _model!.activities.append(al, data['Page']['pageInfo']['hasNextPage']);

    _loading = false;
    update();
  }

  Future<void> toggleFollow() async {
    final data = await Client.request(_toggleFollow, {'id': _model!.id});
    if (data == null) return;
    _model!.toggleFollow(data['ToggleFollow']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}

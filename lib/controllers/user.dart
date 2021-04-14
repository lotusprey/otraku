import 'package:get/get.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/user_model.dart';

class User extends GetxController {
  static const _userQuery = r'''
      query User($id: Int) {
        User(id: $id) {
          ...main
          favourites {
            anime {...media}
            manga {...media}
            characters {...character}
            staff {...staff}
            studios {...studio}
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

  final int id;
  User(this.id);

  UserModel? _model;
  bool _loading = true;

  UserModel? get model => _model;
  List<ActivityModel> get activities => _model!.activities.items;
  bool get loading => _loading;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    final data = await Client.request(
      _userQuery,
      {'id': id},
      popOnErr: id != Client.viewerId,
    );
    if (data == null) return;

    _model = UserModel(data['User'], id == Client.viewerId);
    _model!.addFavs(null, data['User']['favourites']);
    _loading = false;
    update();
  }

  Future<void> fetchActivities() async {
    if (_loading || !_model!.activities.hasNextPage) return;
    _loading = true;

    final data = await Client.request(_activitiesQuery, {
      'id': id,
      'page': _model!.activities.nextPage,
    });
    if (data == null) return;

    final al = <ActivityModel>[];
    for (final a in data['Page']['activities']) {
      final m = ActivityModel(a);
      if (m.valid) al.add(m);
    }
    _model!.activities.append(al, data['Page']['pageInfo']['hasNextPage']);
    _loading = false;
    update();
  }

  Future<void> toggleFollow() async {
    final data = await Client.request(_toggleFollow, {'id': id});
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

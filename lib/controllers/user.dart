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

  static const _toggleFollow =
      r'''mutation FollowUser($id: Int) {ToggleFollow(userId: $id) {isFollowing}}''';

  final int id;
  User(this.id);

  UserModel? _model;

  UserModel? get model => _model;
  List<ActivityModel> get activities => _model!.activities.items;

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

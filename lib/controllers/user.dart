import 'package:get/get.dart';
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
        statistics {anime {...stats} manga {...stats}}
      }
      fragment stats on UserStatistics {
        count
        meanScore
        standardDeviation
        minutesWatched
        episodesWatched
        chaptersRead
        volumesRead
        scores(sort: MEAN_SCORE) {count meanScore minutesWatched chaptersRead score}
        formats {count meanScore minutesWatched chaptersRead format}
        statuses {count meanScore minutesWatched chaptersRead status}
        countries {count meanScore minutesWatched chaptersRead country}
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

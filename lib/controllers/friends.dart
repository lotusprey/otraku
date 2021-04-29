import 'package:get/get.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

class Friends extends ScrollxController {
  static const _friendsQuery = r'''
    query Friends($id: Int!, $page: Int = 1, $withFollowing: Boolean = false, $withFollowers: Boolean = false) {
      following: Page(page: $page) @include(if: $withFollowing) {
        pageInfo {hasNextPage}
        following(userId: $id, sort: USERNAME) {id name avatar {large}}
      }
      followers: Page(page: $page) @include(if: $withFollowers) {
        pageInfo {hasNextPage}
        followers(userId: $id, sort: USERNAME) {id name avatar {large}}
      }
    }
  ''';

  final int id;
  Friends(this.id, this._onFollowing);

  late UserModel _model;
  bool _onFollowing;

  List<BrowseResultModel> get users =>
      _onFollowing ? _model.following.items : _model.followers.items;

  bool get onFollowing => _onFollowing;
  set onFollowing(bool val) {
    _onFollowing = val;
    scrollTo(0).then((_) {
      if (_onFollowing && _model.following.items.isEmpty) fetchPage();
      if (!_onFollowing && _model.followers.items.isEmpty) fetchPage();
      update();
    });
  }

  bool get hasNextPage {
    if (_onFollowing) return _model.following.hasNextPage;
    return _model.followers.hasNextPage;
  }

  Future<void> fetchPage() async {
    Map<String, dynamic>? data = await Client.request(_friendsQuery, {
      'id': id,
      'withFollowing': _onFollowing,
      'withFollowers': !_onFollowing,
      'page':
          _onFollowing ? _model.following.nextPage : _model.followers.nextPage,
    });
    if (data == null) return;

    final users = <BrowseResultModel>[];
    if (_onFollowing) {
      for (final u in data['following']['following'])
        users.add(BrowseResultModel.user(u));
      _model.following.append(
        users,
        data['following']['pageInfo']['hasNextPage'],
      );
    } else {
      for (final u in data['followers']['followers'])
        users.add(BrowseResultModel.user(u));
      _model.followers.append(
        users,
        data['followers']['pageInfo']['hasNextPage'],
      );
    }

    update();
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<User>(tag: id.toString()).model!;
    if (_onFollowing && _model.following.items.isEmpty ||
        !_onFollowing && _model.followers.items.isEmpty) fetchPage();
  }
}

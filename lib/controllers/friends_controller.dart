import 'package:get/get.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class FriendsController extends ScrollingController {
  FriendsController(this.id, this._onFollowing);

  final int id;
  late UserModel _model;
  bool _onFollowing;

  List<ExplorableModel> get users =>
      _onFollowing ? _model.following.items : _model.followers.items;

  bool get onFollowing => _onFollowing;
  set onFollowing(bool val) => scrollUpTo(0).then((_) {
        _onFollowing = val;
        if (_onFollowing &&
            _model.following.items.isEmpty &&
            _model.following.hasNextPage) fetchPage();
        if (!_onFollowing &&
            _model.followers.items.isEmpty &&
            _model.followers.hasNextPage) fetchPage();
        update();
      });

  bool get hasNextPage => _onFollowing
      ? _model.following.hasNextPage
      : _model.followers.hasNextPage;

  @override
  Future<void> fetchPage() async {
    if (_onFollowing && !_model.following.hasNextPage) return;
    if (!_onFollowing && !_model.followers.hasNextPage) return;

    Map<String, dynamic>? data = await Client.request(GqlQuery.friends, {
      'id': id,
      'withFollowing': _onFollowing,
      'withFollowers': !_onFollowing,
      'page':
          _onFollowing ? _model.following.nextPage : _model.followers.nextPage,
    });
    if (data == null) return;

    final users = <ExplorableModel>[];
    if (_onFollowing) {
      for (final u in data['following']['following'])
        users.add(ExplorableModel.user(u));
      _model.following.append(
        users,
        data['following']['pageInfo']['hasNextPage'],
      );
    } else {
      for (final u in data['followers']['followers'])
        users.add(ExplorableModel.user(u));
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
    _model = Get.find<UserController>(tag: id.toString()).model!;
    if (_onFollowing &&
            _model.following.items.isEmpty &&
            _model.following.hasNextPage ||
        !_onFollowing &&
            _model.followers.items.isEmpty &&
            _model.followers.hasNextPage) fetchPage();
  }
}

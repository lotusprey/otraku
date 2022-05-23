import 'package:get/get.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

class UserController extends GetxController {
  UserController(this.id);

  final int id;
  UserModel? _model;

  UserModel? get model => _model;

  Future<void> _fetch() async {
    final data = await Api.request(
      GqlQuery.user,
      {
        'id': id,
        'withMain': true,
        'withStats': true,
        'withAnime': true,
        'withManga': true,
        'withCharacters': true,
        'withStaff': true,
        'withStudios': true,
      },
    );
    if (data == null) return;

    _model = UserModel(data['User'], id == Settings().id);
    _model!.addFavs(null, data['User']['favourites']);
    update();
  }

  Future<void> toggleFollow() async {
    final data = await Api.request(GqlMutation.toggleFollow, {'userId': id});
    if (data == null) return;
    _model!.toggleFollow(data['ToggleFollow']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}

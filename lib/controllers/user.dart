import 'package:get/get.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/models/user_data.dart';

class User extends GetxController {
  static const ME = 'viewer';

  static const _userQuery = r'''
      query User($id: Int) {
        User(id: $id) {
          id
          name
          about(asHtml: true)
          avatar {large}
          bannerImage
          isFollowing
          isFollower
          isBlocked
        }
      }
    ''';

  UserData _user;

  UserData get data => _user;

  Future<void> fetchUser(int id) async {
    final data = await NetworkService.request(_userQuery, {
      'id': id ?? NetworkService.viewerId,
    });

    if (data == null) return;

    _user = UserData(data['User'], id == null);
    update();
  }
}

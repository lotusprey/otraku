import 'package:get/get.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/models/user_data.dart';

class User extends GetxController {
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
    final data = await GraphQl.request(_userQuery, {
      'id': id ?? GraphQl.viewerId,
    });

    if (data == null) return;

    _user = UserData(data['User'], id == null);
    update();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:otraku/models/user.dart';
import 'package:otraku/providers/network_service.dart';

class Users with ChangeNotifier {
  static const _viewerQuery = r'''
    query {
      Viewer {
        id
        name
        about(asHtml: true)
        avatar {large}
        bannerImage
        mediaListOptions {scoreFormat}
      }
    }
  ''';

  static const _userQuery = r'''
      query User($id: Int) {
        User(id: $id) {
          name
          about(asHtml: true)
          avatar {large}
          bannerImage
          isFollowing
          isFollower
          isBlocked
          mediaListOptions {scoreFormat}
        }
      }
    ''';

  User _me;
  User _them;

  User get me => _me;

  User them(int id) {
    if (_them == null || _them.id != id) fetchUser(id);
    return _them;
  }

  Future<void> fetchViewer() async {
    final data =
        await NetworkService.request(_viewerQuery, null, popOnError: false);

    if (data == null) return;

    _me = User(
      id: data['Viewer']['id'],
      name: data['Viewer']['name'],
      description: data['Viewer']['about'],
      avatar: data['Viewer']['avatar']['large'],
      banner: data['Viewer']['bannerImage'],
      isMe: true,
    );

    notifyListeners();
  }

  Future<void> fetchUser(int id) async {
    final data = await NetworkService.request(_userQuery, {'id': id});

    if (data == null) return;

    _them = User(
      id: id,
      name: data['User']['name'],
      description: data['User']['about'],
      avatar: data['User']['avatar']['large'],
      banner: data['User']['bannerImage'],
      isMe: false,
    );

    notifyListeners();
  }
}

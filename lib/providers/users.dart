import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:otraku/models/user.dart';
import 'package:otraku/models/user_settings.dart';

class Users with ChangeNotifier {
  static const _url = 'https://graphql.anilist.co';

  Map<String, String> _headers;

  User _me;
  User _them;
  UserSettings _mySettings;

  void init(Map<String, String> headers, UserSettings userSettings) {
    _headers = headers;
    _mySettings = userSettings;
  }

  User get me => _me;

  User them(int id) {
    if (_them == null || _them.id != id) fetchUser(id);
    return _them;
  }

  UserSettings get settings => _mySettings;

  Future<void> fetchViewer() async {
    final data = await _fetchUserData(_mySettings.userId);

    _me = User(
      id: _mySettings.userId,
      name: data['name'],
      description: data['about'],
      avatar: data['avatar']['large'],
      banner: data['bannerImage'],
      settings: _mySettings,
      isMe: true,
    );

    notifyListeners();
  }

  Future<void> fetchUser(int id) async {
    final data = await _fetchUserData(_mySettings.userId);

    _them = User(
      id: id,
      name: data['name'],
      description: data['about'],
      avatar: data['avatar']['large'],
      banner: data['bannerImage'],
      settings: _mySettings,
      isMe: false,
    );

    notifyListeners();
  }

  Future<Map<String, dynamic>> _fetchUserData(int id) async {
    const query = r'''
      query Profile($id: Int) {
        User(id: $id) {
          name
          about(asHtml: true)
          avatar {large}
          bannerImage
          isFollowing
          isFollower
          isBlocked
          mediaListOptions {
            scoreFormat
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id},
    });

    final response = await post(_url, body: request, headers: _headers);

    return (json.decode(response.body) as Map<String, dynamic>)['data']['User'];
  }
}

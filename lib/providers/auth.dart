import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/auth_enum.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  static AuthStatus _status;
  static String _accessToken;

  static int _userId;
  static String _titleFormat;
  static String _scoreFormat;
  static MediaListSort _animeSort;
  static MediaListSort _mangaSort;

  AuthStatus get status {
    return _status;
  }

  Map<String, String> get headers {
    return {
      'Authorization': 'Bearer $_accessToken',
      'Accept': 'application/json',
      'Content-type': 'application/json',
    };
  }

  String get titleFormat {
    return _titleFormat;
  }

  String get scoreFormat {
    return _scoreFormat;
  }

  MediaListSort get animeSort {
    return _animeSort;
  }

  MediaListSort get mangaSort {
    return _mangaSort;
  }

  int get userId {
    if (_userId == null) {
      throw "The user id isn't set";
    }

    return _userId;
  }

  Future<void> setAccessToken(String value) async {
    _accessToken = value;

    await validateAccessToken();
    if (_status != AuthStatus.authorised) {
      _accessToken = null;
      throw ('Could not set access token. Status: ${describeEnum(status)}');
    }

    final storage = FlutterSecureStorage();
    storage.write(key: 'accessToken', value: value);
  }

  Future<void> logOut() async {
    final storage = FlutterSecureStorage();
    storage.delete(key: 'accessToken');

    _userId = null;
    _accessToken = null;
    notifyListeners();
  }

  Future<void> validateAccessToken() async {
    if (_accessToken == null) {
      final storage = FlutterSecureStorage();
      _accessToken = await storage.read(key: 'accessToken');

      if (_accessToken == null) {
        _status = AuthStatus.emptyToken;
        return;
      }
    }

    const url = 'https://graphql.anilist.co';

    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Accept': 'application/json',
      'Content-type': 'application/json',
    };

    const query = '''
      query MyId {
        Viewer {
          id
          options {
            titleLanguage
          }
          mediaListOptions {
            scoreFormat
          }
        }
      }
    ''';

    final request = json.encode({'query': query});

    final response = await post(
      url,
      headers: headers,
      body: request,
    );

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (body.containsKey('errors')) {
      Map<String, dynamic> error = (body['errors'] as List<dynamic>)[0];

      if (error['message'] == 'Invalid token') {
        _status = AuthStatus.invalidToken;
        return;
      } else if (error['message'] == 'Unauthorized.') {
        _status = AuthStatus.unauthorised;
        return;
      }

      _status = AuthStatus.serverProblem;
      return;
    }

    final viewer = body['data']['Viewer'];

    _userId = viewer['id'];
    _titleFormat = viewer['options']['titleLanguage'];
    _scoreFormat = viewer['mediaListOptions']['scoreFormat'];

    final preferrences = await SharedPreferences.getInstance();

    int index = preferrences.getInt('animeSort');
    if (index != null) {
      _animeSort = MediaListSort.values[index];
    } else {
      _animeSort = MediaListSort.TITLE;
      preferrences.setInt('animeSort', MediaListSort.TITLE.index);
    }

    index = preferrences.getInt('mangaSort');
    if (index != null) {
      _mangaSort = MediaListSort.values[index];
    } else {
      _mangaSort = MediaListSort.TITLE;
      preferrences.setInt('mangaSort', MediaListSort.TITLE.index);
    }

    _status = AuthStatus.authorised;
    notifyListeners();
  }
}

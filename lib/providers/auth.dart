import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/auth_enum.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  static AuthStatus _status;
  static String _accessToken;
  static UserSettings _userSettings;

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

  UserSettings get userSettings => _userSettings;

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

    const query = '''
      query MyId {
        Viewer {
          id
          options {
            titleLanguage
            displayAdultContent
          }
          mediaListOptions {
            scoreFormat
            animeList {
              splitCompletedSectionByFormat
            }
            mangaList {
              splitCompletedSectionByFormat
            }
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

    final view = body['data']['Viewer'];
    final preferrences = await SharedPreferences.getInstance();
    int index = preferrences.getInt('sort');

    _userSettings = UserSettings(
      userId: view['id'],
      scoreFormat: view['mediaListOptions']['scoreFormat'],
      splitCompletedAnime: view['mediaListOptions']['animeList']
          ['splitCompletedSectionByFormat'],
      splitCompletedManga: view['mediaListOptions']['mangaList']
          ['splitCompletedSectionByFormat'],
      sort: index != null ? MediaListSort.values[index] : MediaListSort.TITLE,
      titleFormat: view['options']['titleLanguage'],
      displayAdultContent: view['options']['displayAdultContent'],
    );

    _status = AuthStatus.authorised;
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/auth_enum.dart';

class Auth with ChangeNotifier {
  static AuthStatus _status;
  static String _accessToken;

  static int _userId;
  static String _scoreFormat;

  AuthStatus get status {
    return _status;
  }

  String get accessToken {
    return _accessToken;
  }

  String get scoreFormat {
    return _scoreFormat;
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

    final query = '''
      query MyId {
        Viewer {
          id
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

    _userId = body['data']['Viewer']['id'];
    _scoreFormat = body['data']['Viewer']['mediaListOptions']['scoreFormat'];

    _status = AuthStatus.authorised;
    notifyListeners();
  }
}

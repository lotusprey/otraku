import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/auth_enum.dart';
import 'package:otraku/providers/network_service.dart';

class Auth with ChangeNotifier {
  AuthStatus _status;
  String _accessToken;
  int _viewerId;

  int get viewerId => _viewerId;

  AuthStatus get status => _status;

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
        }
      }
    ''';

    final request = json.encode({'query': query});

    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Accept': 'application/json',
      'Content-type': 'application/json',
    };

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

    _viewerId = body['data']['Viewer']['id'];

    NetworkService.headers = headers;

    _status = AuthStatus.authorised;
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/routing/navigation.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

abstract class Client {
  static final _url = Uri.parse('https://graphql.anilist.co');

  static const _idQuery = 'query Id {Viewer {id}}';

  static const _TOKEN_KEY = 'accessToken1';
  static const _ID_KEY = 'viewerId1';
  static const _EXPIRATION_KEY = 'expirationMillis1';

  static final Map<String, String> _headers = {
    'Authorization': 'Bearer $_accessToken',
    'Accept': 'application/json',
    'Content-type': 'application/json',
  };

  static String? _accessToken;
  static int? _viewerId;
  static int? get viewerId => _viewerId;

  // Sets new credentials, when acquiring a token.
  static setCredentials(String token, int expiration) {
    _accessToken = token;
    FlutterSecureStorage().write(key: _TOKEN_KEY, value: _accessToken);
    Config.storage.write(
      _EXPIRATION_KEY,
      DateTime.now()
          .add(Duration(seconds: expiration, days: -1))
          .millisecondsSinceEpoch,
    );
  }

  // Verifies credentials.
  static Future<bool> logIn() async {
    if (_accessToken == null) {
      // Check the token's expiration date.
      final int? millis = Config.storage.read(_EXPIRATION_KEY);
      if (millis != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(millis);
        if (DateTime.now().compareTo(date) >= 0) {
          FlutterSecureStorage().deleteAll();
          Config.storage.remove(_ID_KEY);
          Config.storage.remove(_EXPIRATION_KEY);
          return false;
        }
      }

      // Try to acquire the token from the secure storage.
      _accessToken = await FlutterSecureStorage().read(key: _TOKEN_KEY);
      if (_accessToken == null) return false;
    }

    // Try to acquire the viewer's id from the storage.
    if (_viewerId == null) _viewerId = Config.storage.read(_ID_KEY);

    // Fetch the viewer's id, if needed.
    if (_viewerId == null) {
      final data = await request(_idQuery);
      if (data == null) return false;
      _viewerId = data['Viewer']['id'];
      Config.storage.write(_ID_KEY, _viewerId);
    }

    return true;
  }

  // Clears all data and logs out.
  static Future<void> logOut() async {
    FlutterSecureStorage().deleteAll();
    Config.storage.erase();
    _accessToken = null;
    _viewerId = null;
    Navigation.it.setBasePage(Navigation.authRoute);
  }

  // The app needs both the accessToken and the viewer id.
  static bool loggedIn() => _accessToken != null && _viewerId != null;

  // Sends a request to the site.
  static Future<Map<String, dynamic>?> request(
    String query, [
    Map<String, dynamic>? variables,
  ]) async {
    IOException? err;

    final response = await post(
      _url,
      body: json.encode({'query': query, 'variables': variables}),
      headers: _headers,
    ).catchError((e) => err = e);

    if (err != null) {
      _handleErr(ioErr: err);
      return null;
    }

    if (response.body.isEmpty) {
      _handleErr(apiErr: ['Empty AniList response...']);
      return null;
    }

    final Map<String, dynamic> body = json.decode(response.body);

    if (body.containsKey('errors')) {
      final List<String> messages = (body['errors'] as List<dynamic>)
          .map((e) => e['message'].toString())
          .toList();

      _handleErr(apiErr: messages);

      return null;
    }

    return body['data'];
  }

  // Handle errors that have occured after fetching.
  static void _handleErr({
    IOException? ioErr,
    List<String>? apiErr,
  }) {
    assert(ioErr != null || apiErr != null);

    final context = Navigation.it.ctx;
    if (context == null) return;

    if (ioErr != null) {
      showPopUp(
        context,
        ConfirmationDialog(
          content: ioErr.toString(),
          title: ioErr is SocketException
              ? 'Internet connection problem'
              : 'Device request failed',
          mainAction: 'Ok',
        ),
      );

      return;
    }

    if (apiErr != null &&
        (apiErr.contains('Unauthorized.') ||
            apiErr.contains('Invalid token'))) {
      Navigation.it.setBasePage(Navigation.authRoute);
      return;
    }

    showPopUp(
      context,
      ConfirmationDialog(
        content: apiErr?.join('\n'),
        title: 'Faulty query',
        mainAction: 'Ok',
      ),
    );
  }
}

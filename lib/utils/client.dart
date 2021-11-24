import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/navigation.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

abstract class Client {
  static final _url = Uri.parse('https://graphql.anilist.co');

  static const _idQuery = 'query Id {Viewer {id}}';

  //
  //
  //
  // LEGACY CODE. To be removed after the next update.
  static const _TOKEN_KEY = 'accessToken1';
  //
  //
  //

  static const _HEADERS_AUTH_KEY = 'Authorization';
  static const _TOKEN_0 = 'token0';
  static const _TOKEN_1 = 'token1';

  static final Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-type': 'application/json',
  };

  static String? _accessToken;

  static set _token(String? v) {
    _accessToken = v;
    v != null
        ? _headers[_HEADERS_AUTH_KEY] = 'Bearer $_accessToken'
        : _headers.remove(_HEADERS_AUTH_KEY);
  }

  // Save credentials to an account.
  static Future<void> register(
    bool primary,
    String token,
    int expiration,
  ) async {
    await FlutterSecureStorage().write(
      key: primary ? _TOKEN_0 : _TOKEN_1,
      value: token,
    );

    expiration = DateTime.now()
        .add(Duration(seconds: expiration, days: -1))
        .millisecondsSinceEpoch;

    primary
        ? LocalSettings().expiration0 = expiration
        : LocalSettings().expiration1 = expiration;
  }

  // Try loading a saved account.
  static Future<bool> logIn(bool primary) async {
    //
    //
    //
    // LEGACY CODE. To be removed after the next update.
    FlutterSecureStorage().delete(key: _TOKEN_KEY);
    //
    //
    //

    LocalSettings.onPrimaryAccount = primary;

    if (_accessToken == null) {
      // Check the token's expiration date.
      if (LocalSettings().expiration != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          LocalSettings().expiration!,
        );
        if (DateTime.now().compareTo(date) >= 0) {
          removeAccount(primary);
          return false;
        }
      }

      // Try to acquire the token from the storage.
      _token =
          await FlutterSecureStorage().read(key: primary ? _TOKEN_0 : _TOKEN_1);

      if (_accessToken == null) {
        LocalSettings.onPrimaryAccount = null;
        return false;
      }
    }

    // Fetch the viewer's id, if needed.
    if (LocalSettings().id == null) {
      final data = await request(_idQuery);
      LocalSettings().id = data?['Viewer']?['id'];
      if (LocalSettings().id == null) {
        LocalSettings.onPrimaryAccount = null;
        _token = null;
        return false;
      }
    }

    // Set up background tasks.
    BackgroundHandler.init();

    return true;
  }

  // Log out and show available accounts.
  static Future<void> logOut() async {
    _token = null;
    LocalSettings.onPrimaryAccount = null;
    BackgroundHandler.dispose();
    Navigation().setBasePage(Navigation.authRoute);
  }

  // Remove a saved account.
  static void removeAccount(bool primary) async {
    if (primary) {
      LocalSettings().id0 = null;
      LocalSettings().expiration0 = null;
      await FlutterSecureStorage().delete(key: _TOKEN_0);
    } else {
      LocalSettings().id1 = null;
      LocalSettings().expiration1 = null;
      await FlutterSecureStorage().delete(key: _TOKEN_1);
    }
  }

  // The app needs both the accessToken and the viewer id.
  static bool loggedIn() => _accessToken != null && LocalSettings().id != null;

  // Send a request to the site.
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

    final context = Navigation().ctx;
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
      Navigation().setBasePage(Navigation.authRoute);
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/utils/route_arg.dart';
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
    int account,
    String token,
    int expiration,
  ) async {
    if (account < 0 || account > 1) return;

    await FlutterSecureStorage().write(
      key: account == 0 ? _TOKEN_0 : _TOKEN_1,
      value: token,
    );

    expiration = DateTime.now()
        .add(Duration(seconds: expiration, days: -1))
        .millisecondsSinceEpoch;

    LocalSettings().setExpirationOf(account, expiration);
  }

  // Try loading a saved account.
  static Future<bool> logIn(int account) async {
    //
    //
    //
    // LEGACY CODE. To be removed after the next update.
    FlutterSecureStorage().delete(key: _TOKEN_KEY);
    //
    //
    //
    if (account < 0 || account > 1) return false;

    if (_accessToken == null) {
      // Check the token's expiration date.
      if (LocalSettings().expirationOf(account) != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          LocalSettings().expirationOf(account)!,
        );
        if (DateTime.now().compareTo(date) >= 0) {
          removeAccount(account);
          return false;
        }
      }

      // Try to acquire the token from the storage.
      _token = await FlutterSecureStorage()
          .read(key: account == 0 ? _TOKEN_0 : _TOKEN_1);

      if (_accessToken == null) return false;
    }

    // Fetch the viewer's id, if needed.
    if (LocalSettings().idOf(account) == null) {
      final data = await request(_idQuery);
      LocalSettings().setIdOf(account, data?['Viewer']?['id']);
      if (LocalSettings().idOf(account) == null) {
        _token = null;
        return false;
      }
    }

    return true;
  }

  // Log out and show available accounts.
  static Future<void> logOut() async {
    _token = null;
    LocalSettings.selectedAccount = null;
    BackgroundHandler.clearNotifications();
    final context = RouteArg.navKey.currentContext;
    if (context == null) return;
    Navigator.pushNamedAndRemoveUntil(context, RouteArg.auth, (_) => false);
  }

  // Remove a saved account.
  static void removeAccount(int account) async {
    LocalSettings().setIdOf(account, null);
    LocalSettings().setExpirationOf(account, null);
    await FlutterSecureStorage()
        .delete(key: account == 0 ? _TOKEN_0 : _TOKEN_1);
  }

  static bool loggedIn() => _accessToken != null;

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

    final context = RouteArg.navKey.currentContext;
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
      Navigator.pushNamedAndRemoveUntil(context, RouteArg.auth, (_) => false);
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

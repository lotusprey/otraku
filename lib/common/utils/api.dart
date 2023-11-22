import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/routing.dart';

abstract class Api {
  static final _url = Uri.parse('https://graphql.anilist.co');

  static const _TOKEN_0 = 'token0';
  static const _TOKEN_1 = 'token1';

  static String? _accessToken;

  static Future<void> init() async {
    final account = Options().account;
    if (account == null) return Future.value();
    if (_didAccountExpire(account)) return Future.value();

    _accessToken = await const FlutterSecureStorage()
        .read(key: account == 0 ? _TOKEN_0 : _TOKEN_1);
  }

  static bool isSessionActive() => _accessToken != null;

  static bool _didAccountExpire(int account) {
    if (Options().expirationOf(account) == null) return false;

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(
      Options().expirationOf(account)!,
    );

    if (DateTime.now().compareTo(expirationDate) < 0) {
      return false;
    }

    removeAccount(account);
    return true;
  }

  // Save credentials to an account.
  static Future<void> register(
    int account,
    String token,
    int expiration,
  ) async {
    if (account < 0 || account > 1) return;

    await const FlutterSecureStorage().write(
      key: account == 0 ? _TOKEN_0 : _TOKEN_1,
      value: token,
    );

    expiration = DateTime.now()
        .add(Duration(seconds: expiration, days: -1))
        .millisecondsSinceEpoch;

    Options().setExpirationOf(account, expiration);
  }

  // Try loading a saved account.
  static Future<bool> logIn(int account) async {
    if (account < 0 || account > 1) return false;

    if (_accessToken == null) {
      if (_didAccountExpire(account)) return false;

      // Try to acquire the token from the storage.
      _accessToken = await const FlutterSecureStorage()
          .read(key: account == 0 ? _TOKEN_0 : _TOKEN_1);

      if (_accessToken == null) return false;
    }

    // Fetch the viewer's id, if needed.
    if (Options().idOf(account) == null) {
      try {
        final data = await get('query Id {Viewer {id}}');
        Options().setIdOf(account, data['Viewer']?['id']);
        if (Options().idOf(account) == null) {
          _accessToken = null;
          return false;
        }
      } catch (_) {
        return false;
      }
    }

    return true;
  }

  // Log out and show available accounts.
  static Future<void> logOut(BuildContext context) async {
    _accessToken = null;
    Options().selectedAccount = null;
    context.go(Routes.auth);
  }

  // Remove a saved account.
  static Future<void> removeAccount(int account) async {
    Options().setIdOf(account, null);
    Options().setExpirationOf(account, null);
    await const FlutterSecureStorage()
        .delete(key: account == 0 ? _TOKEN_0 : _TOKEN_1);
  }

  static bool loggedIn() => _accessToken != null;

  // Send a request.
  static Future<Map<String, dynamic>> get(
    String query, [
    Map<String, dynamic> variables = const {},
  ]) async {
    try {
      final response = await post(
        _url,
        body: json.encode({'query': query, 'variables': variables}),
        headers: {
          'Accept': 'application/json',
          'Content-type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 20));

      final Map<String, dynamic> body = json.decode(response.body);

      if (body.containsKey('errors')) {
        throw StateError(
          (body['errors'] as List).map((e) => e['message'].toString()).join(),
        );
      }

      return body['data'];
    } on TimeoutException {
      throw Exception('Request took too long');
    }
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/common/utils/options.dart';

abstract class Api {
  static final _url = Uri.parse('https://graphql.anilist.co');

  static const _TOKEN_0 = 'token0';
  static const _TOKEN_1 = 'token1';

  static String? _accessToken;

  static Future<bool> init() async {
    final account = Options().selectedAccount;
    if (account == null) return false;
    if (_didAccountExpire(account)) return false;

    _accessToken = await const FlutterSecureStorage()
        .read(key: account == 0 ? _TOKEN_0 : _TOKEN_1);
    return true;
  }

  static bool hasActiveAccount() => _accessToken != null;

  static Future<bool> selectAccount(int account) async {
    if (Options().idOf(account) == null) return false;
    if (_didAccountExpire(account)) return false;

    _accessToken = await const FlutterSecureStorage()
        .read(key: account == 0 ? _TOKEN_0 : _TOKEN_1);
    if (_accessToken == null) return false;

    Options().selectedAccount = account;
    return true;
  }

  static Future<void> unselectAccount() async {
    _accessToken = null;
    Options().selectedAccount = null;
  }

  static Future<bool> addAccount(
    int account,
    String token,
    int expiration,
  ) async {
    if (account < 0 || account > 1) return false;

    _accessToken = token;
    try {
      final data = await get('query Id {Viewer {id}}');
      final id = data['Viewer']?['id'];
      if (id == null) {
        _accessToken = null;
        return false;
      }

      Options().setIdOf(account, id);
    } catch (_) {
      _accessToken = null;
      return false;
    }

    await const FlutterSecureStorage().write(
      key: account == 0 ? _TOKEN_0 : _TOKEN_1,
      value: token,
    );

    expiration = DateTime.now()
        .add(Duration(seconds: expiration, days: -1))
        .millisecondsSinceEpoch;
    Options().setExpirationOf(account, expiration);
    Options().selectedAccount = account;
    return true;
  }

  static Future<void> removeAccount(int account) async {
    Options().setIdOf(account, null);
    Options().setExpirationOf(account, null);
    await const FlutterSecureStorage()
        .delete(key: account == 0 ? _TOKEN_0 : _TOKEN_1);
  }

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

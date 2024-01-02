import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/auth/account.dart';

abstract class Api {
  static final _url = Uri.parse('https://graphql.anilist.co');

  static String? _accessToken;

  static Future<bool> init() async {
    if (Options().selectedAccount == null) return false;
    final account = Options().accounts[Options().selectedAccount!];
    if (DateTime.now().compareTo(account.expiration) >= 0) return false;

    _accessToken = await const FlutterSecureStorage().read(key: _key(account));
    return true;
  }

  static bool hasActiveAccount() => _accessToken != null;

  static Future<bool> selectAccount(int index) async {
    if (index < 0 || index >= Options().accounts.length) return false;

    final account = Options().accounts[index];
    if (DateTime.now().compareTo(account.expiration) >= 0) return false;

    Options().selectedAccount = index;
    _accessToken = await const FlutterSecureStorage().read(key: _key(account));
    return true;
  }

  static Future<void> unselectAccount() async {
    _accessToken = null;
    Options().selectedAccount = null;
  }

  static Future<bool> addAccount(
    String token,
    int secondsLeftBeforeExpiration,
  ) async {
    _accessToken = token;
    try {
      final data = await get('query Viewer {Viewer {id name avatar {large}}}');
      final id = data['Viewer']?['id'];
      final name = data['Viewer']?['name'];
      final avatarUrl = data['Viewer']?['avatar']?['large'];
      if (id == null || name == null || avatarUrl == null) {
        _accessToken = null;
        return false;
      }

      if (Options().accounts.indexWhere((a) => a.id == id) > -1) return true;

      final expiration = DateTime.now()
          .add(Duration(seconds: secondsLeftBeforeExpiration, days: -1));
      final account = Account(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        expiration: expiration,
      );

      Options().accounts = [...Options().accounts, account];
      await const FlutterSecureStorage()
          .write(key: _key(account), value: token);
      return true;
    } catch (_) {
      _accessToken = null;
      return false;
    }
  }

  static Future<void> removeAccount(int index) async {
    final account = Options().accounts.elementAtOrNull(index);
    if (account == null) return;

    final selectedAccount = Options().selectedAccount;
    if (selectedAccount != null && selectedAccount >= index) {
      Options().selectedAccount = null;
    }

    await const FlutterSecureStorage().delete(key: _key(account));
    Options().accounts.removeAt(index);
    Options().accounts = Options().accounts;
  }

  static String _key(Account account) => 'auth${account.id}';

  /// Send a GraphQL request.
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

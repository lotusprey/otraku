import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/pages/auth_page.dart';

class Client {
  Client._();

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

  static Future<bool> logIn() async {
    if (_accessToken == null) {
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

      _accessToken = await FlutterSecureStorage().read(key: _TOKEN_KEY);
      if (_accessToken == null) return false;
    }

    _viewerId = Config.storage.read(_ID_KEY);
    if (_viewerId == null) {
      final data = await request(_idQuery, null, popOnErr: false);
      if (data == null) return false;
      _viewerId = data['Viewer']['id'];
      Config.storage.write(_ID_KEY, _viewerId);
    }

    return true;
  }

  static Future<void> logOut() async {
    FlutterSecureStorage().deleteAll();
    Config.storage.erase();
    _accessToken = null;
    _viewerId = null;
    Get.offAllNamed(AuthPage.ROUTE);
  }

  static Future<Map<String, dynamic>?> request(
    String request,
    Map<String, dynamic>? variables, {
    bool popOnErr = true,
    bool silentErr = false,
  }) async {
    bool erred = false;

    final response = await post(
      _url,
      body: json.encode({'query': request, 'variables': variables}),
      headers: _headers,
    ).catchError((err) {
      if (!silentErr) _handleErr(popOnErr, ioErr: err as IOException);
      erred = true;
    });

    if (erred || response.body.isEmpty) {
      if (!silentErr)
        _handleErr(popOnErr, apiErr: ['Empty AniList response...']);
      return null;
    }

    final Map<String, dynamic> body = json.decode(response.body);

    if (body.containsKey('errors')) {
      final List<String> messages = (body['errors'] as List<dynamic>)
          .map((e) => e['message'].toString())
          .toList();

      if (!silentErr) _handleErr(popOnErr, apiErr: messages);

      return null;
    }

    return body['data'];
  }

  static void _handleErr(
    bool popOnErr, {
    IOException? ioErr,
    List<String>? apiErr,
  }) {
    if (popOnErr) Get.back();

    if (ioErr != null && ioErr is SocketException) {
      Get.defaultDialog(
        radius: 10,
        backgroundColor: Get.theme.backgroundColor,
        titleStyle: Get.theme.textTheme.headline5,
        title: 'Internet connection problem',
        content: Text(ioErr.toString()),
        actions: [TextButton(child: Text('Ok'), onPressed: Get.back)],
      );
      return;
    }

    if (apiErr != null &&
        (apiErr.contains('Unauthorized.') ||
            apiErr.contains('Invalid token'))) {
      Get.offAllNamed(AuthPage.ROUTE);
      return;
    }

    final text = ioErr?.toString() ?? apiErr!.join('\n');

    Get.defaultDialog(
      radius: 10,
      backgroundColor: Get.theme.backgroundColor,
      titleStyle: Get.theme.textTheme.headline5,
      title:
          ioErr == null ? 'A query error occured' : 'A request error occured',
      content: Text(text),
      actions: [TextButton(child: Text('Sad'), onPressed: Get.back)],
    );
  }
}

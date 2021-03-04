import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/auth_page.dart';

class Client {
  Client._();

  static final _url = Uri.https('graphql.anilist.co', '');

  static const String _idQuery = 'query Id {Viewer {id}}';

  static final Map<String, String> _headers = {
    'Authorization': 'Bearer $_accessToken',
    'Accept': 'application/json',
    'Content-type': 'application/json',
  };

  static String _accessToken;

  static int _viewerId;

  static get viewerId => _viewerId;

  static set accessToken(String token) {
    _accessToken = token;
    FlutterSecureStorage().write(key: 'accessToken1', value: _accessToken);
  }

  static Future<bool> logIn() async {
    if (_accessToken == null) {
      _accessToken = await FlutterSecureStorage().read(key: 'accessToken1');
      if (_accessToken == null) return false;
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

  static Future<bool> initViewerId() async {
    _viewerId = Config.storage.read('viewerId1');
    if (_viewerId == null) {
      final data = await request(_idQuery, null, popOnErr: false);
      if (data == null) return false;
      _viewerId = data['Viewer']['id'];
      Config.storage.write('viewerId1', _viewerId);
    }
    return true;
  }

  static Future<Map<String, dynamic>> request(
    String request,
    Map<String, dynamic> variables, {
    bool popOnErr = true,
  }) async {
    bool erred = false;

    final response = await post(
      _url,
      body: json.encode({'query': request, 'variables': variables}),
      headers: _headers,
    ).catchError((err) {
      _handleErr(popOnErr, ioErr: err as IOException);
      erred = true;
    });

    if (erred || response.body.isEmpty) {
      _handleErr(popOnErr, apiErr: ['Empty AniList response...']);
      return null;
    }

    final Map<String, dynamic> body = json.decode(response.body);

    if (body.containsKey('errors')) {
      final List<String> messages = (body['errors'] as List<dynamic>)
          .map((e) => e['message'].toString())
          .toList();

      _handleErr(popOnErr, apiErr: messages);

      return null;
    }

    return body['data'];
  }

  static void _handleErr(
    bool popOnErr, {
    IOException ioErr,
    List<String> apiErr,
  }) {
    if (popOnErr) Get.back();

    if (ioErr != null && ioErr is SocketException) {
      Get.defaultDialog(
        radius: 5,
        backgroundColor: Get.theme.backgroundColor,
        titleStyle: Get.theme.textTheme.headline3,
        title: 'Internet connection problem',
        content: Text(ioErr.toString(), style: Get.theme.textTheme.bodyText1),
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

    final text = ioErr?.toString() ?? apiErr.join('\n');

    Get.defaultDialog(
      radius: 5,
      backgroundColor: Get.theme.backgroundColor,
      titleStyle: Get.theme.textTheme.headline3,
      title:
          ioErr == null ? 'A query error occured' : 'A request error occured',
      content: Text(text, style: Get.theme.textTheme.bodyText1),
      actions: [TextButton(child: Text('Sad'), onPressed: Get.back)],
    );
  }
}

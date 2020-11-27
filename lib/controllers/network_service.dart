import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/auth_page.dart';

class NetworkService {
  static const String _url = 'https://graphql.anilist.co';

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

  static Future<void> initViewerId() async {
    _viewerId = Config.storage.read('viewerId');
    if (_viewerId == null) {
      final data = await request(_idQuery, null, popOnError: false);
      if (data != null) _viewerId = data['Viewer']['id'];
    }
  }

  static Future<Map<String, dynamic>> request(
    String request,
    Map<String, dynamic> variables, {
    bool popOnError = true,
  }) async {
    bool erred = false;

    final response = await post(
      _url,
      body: json.encode({'query': request, 'variables': variables}),
      headers: _headers,
    ).catchError((err) {
      _handleError(popOnError, ioErr: err as IOException);
      erred = true;
    });

    if (erred) return null;

    final Map<String, dynamic> body = json.decode(response.body);

    if (body.containsKey('errors')) {
      final List<String> messages = (body['errors'] as List<dynamic>)
          .map((e) => e['message'].toString())
          .toList();

      _handleError(popOnError, apiErr: messages);

      return null;
    }

    return body['data'];
  }

  static void _handleError(
    bool popOnError, {
    IOException ioErr,
    List<String> apiErr,
  }) {
    if (popOnError) Get.back();

    if (ioErr != null && ioErr is SocketException) {
      Get.defaultDialog(
        radius: 5,
        backgroundColor: Get.theme.backgroundColor,
        titleStyle: Get.theme.textTheme.headline3,
        title: 'Internet connection problem',
        content: Text(ioErr.toString(), style: Get.theme.textTheme.bodyText1),
        actions: [
          FlatButton(
            child: Text('OK', style: Get.theme.textTheme.bodyText2),
            onPressed: Get.back,
          ),
        ],
      );
      return;
    }

    if (!apiErr.isNull &&
        (apiErr.contains('Unauthorized.') ||
            apiErr.contains('Invalid token'))) {
      Get.offAll(AuthPage());
      return;
    }

    final text = !ioErr.isNull ? ioErr.toString() : apiErr.join('\n');

    Get.defaultDialog(
      radius: 5,
      backgroundColor: Get.theme.backgroundColor,
      titleStyle: Get.theme.textTheme.headline3,
      title: ioErr.isNull ? 'A query error occured' : 'A request error occured',
      content: Text(text, style: Get.theme.textTheme.bodyText1),
      actions: [
        FlatButton(
          child: Text('OK', style: Get.theme.textTheme.bodyText2),
          onPressed: Get.back,
        ),
      ],
    );
  }
}

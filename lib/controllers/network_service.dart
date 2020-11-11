import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
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
    final box = GetStorage();
    _viewerId = box.read('viewerId');
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
    final response = await post(
      _url,
      body: json.encode({'query': request, 'variables': variables}),
      headers: _headers,
    ).catchError((err) {
      _handleError(popOnError, [err.toString()], false);
      return null;
    });

    final Map<String, dynamic> body = json.decode(response.body);

    if (body.containsKey('errors')) {
      final List<String> messages = (body['errors'] as List<dynamic>)
          .map((e) => e['message'].toString())
          .toList();

      _handleError(popOnError, messages, true);

      return null;
    }

    return body['data'];
  }

  static void _handleError(
    bool popOnError,
    List<String> errors,
    bool onQuery,
  ) {
    if (errors.contains('Unauthorized.') || errors.contains('Invalid token')) {
      Get.offAll(AuthPage());
      return;
    }

    if (popOnError) Get.back();

    Get.defaultDialog(
      radius: 5,
      backgroundColor: Get.theme.backgroundColor,
      titleStyle: Get.theme.textTheme.headline3,
      title: onQuery ? 'A query error occured' : 'A request error occured',
      content: Text(
        errors.join('\n'),
        style: Get.theme.textTheme.bodyText1,
      ),
      actions: [
        FlatButton(
          child: Text('OK', style: Get.theme.textTheme.bodyText2),
          onPressed: Get.back,
        ),
      ],
    );
  }
}

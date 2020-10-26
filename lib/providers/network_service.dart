import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

class NetworkService {
  static const String _url = 'https://graphql.anilist.co';

  static Map<String, String> _headers;

  static set headers(Map<String, String> headers) => _headers = headers;

  static Future<Map<String, dynamic>> request(
    String query,
    Map<String, dynamic> variables, {
    bool popOnError = true,
  }) async {
    final response = await post(
      _url,
      body: json.encode({'query': query, 'variables': variables}),
      headers: _headers,
    );

    final Map<String, dynamic> body = json.decode(response.body);

    if (body.containsKey('errors')) {
      final List<String> messages = (body['errors'] as List<dynamic>)
          .map((e) => e['message'].toString())
          .toList();

      if (popOnError) Get.back();

      Get.defaultDialog(
        backgroundColor: Get.theme.backgroundColor,
        titleStyle: Get.theme.textTheme.headline3,
        title: 'An error occured',
        content: Text(
          messages.join('\n'),
          style: Get.theme.textTheme.bodyText1,
        ),
        actions: [
          FlatButton(
            child: Text('Ok :(', style: Get.theme.textTheme.bodyText2),
            onPressed: Get.back,
          ),
        ],
      );

      return null;
    }

    return body['data'];
  }
}
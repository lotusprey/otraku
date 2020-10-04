import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/character_data.dart';

class PageItem {
  static const String _url = 'https://graphql.anilist.co';
  static const String ANIME = 'anime';
  static const String MANGA = 'manga';
  static const String CHARACTER = 'character';
  static const String STAFF = 'staff';
  static const String STUDIO = 'studio';

  final Map<String, String> _headers;

  PageItem(this._headers);

  Future<CharacterData> fetchCharacter(int id) async {
    const query = r'''
      query Character($id: Int) {
        Character(id: $id) {
          name {
            full
            native
            alternative
          }
          image {
            large
          }
          description(asHtml: true)
          isFavourite
          favourites
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id},
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = json.decode(result.body)['data']['Character'];
    return CharacterData(
      id: id,
      fullName: data['name']['full'],
      altNames: (data['name']['alternative'] as List<dynamic>)
          .map((a) => a.toString())
          .toList()
            ..insert(0, data['name']['native'].toString()),
      imageUrl: data['image']['large'],
      description:
          data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
    );
  }

  Future<bool> toggleFavourite(int id, Browsable browsable) async {
    String idName = const {
      Browsable.anime: 'anime',
      Browsable.manga: 'manga',
      Browsable.characters: 'character',
    }[browsable];

    final query = '''
      mutation(\$id: Int) {
        ToggleFavourite(${idName}Id: \$id) {
          ${describeEnum(browsable)}(page: 1, perPage: 1) {
            pageInfo {
              currentPage
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id},
    });

    final result = await post(_url, body: request, headers: _headers);
    return !(json.decode(result.body) as Map<String, dynamic>)
        .containsKey('errors');
  }
}

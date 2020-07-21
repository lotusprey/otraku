import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class AllMedia with ChangeNotifier {
  static const String _url = 'https://graphql.anilist.co';

  Map<String, String> _headers;

  AllMedia(String accessToken) {
    _headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-type': 'application/json',
    };
  }

  Future<List<Map<String, dynamic>>> fetchMedia(
      Map<String, dynamic> filters) async {
    const query = r'''
      query Filter($page: Int, $perPage: Int, $id_not_in: [Int], 
          $sort: [MediaSort], $type: MediaType, $search: String, 
          $genre_in: [String], $genre_not_in: [String], $tag_in: [String], 
          $tag_not_in: [String]) {
        Page(page: $page, perPage: $perPage) {
          media(id_not_in: $id_not_in, sort: $sort, type: $type, 
          search: $search, genre_in: $genre_in, genre_not_in: $genre_not_in, 
          tag_in: $tag_in, tag_not_in: $tag_not_in) {
            id
            title {
              userPreferred
            }
            coverImage {
              large
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': filters,
    });

    final response = await post(_url, body: request, headers: _headers);

    final body = json.decode(response.body) as Map<String, dynamic>;

    return (body['data']['Page']['media'] as List<dynamic>)
        .map((m) => {
              'title': m['title']['userPreferred'],
              'imageUrl': m['coverImage']['large'],
              'id': m['id'],
            })
        .toList();
  }

  Future<List<String>> fetchGenres() async {
    final request = json.encode({
      'query': r'''
        query Genres {
          GenreCollection
        }
      ''',
    });

    final response = await post(_url, body: request, headers: _headers);

    final List<dynamic> body =
        json.decode(response.body)['data']['GenreCollection'];

    return body.map((g) => g.toString()).toList();
  }

  Future<List<Map<String, String>>> fetchTags() async {
    final request = json.encode({
      'query': r'''
        query Tags {
          MediaTagCollection {
            name
            description
          }
        }
      ''',
    });

    final response = await post(_url, body: request, headers: _headers);

    final List<dynamic> body =
        json.decode(response.body)['data']['MediaTagCollection'];

    return body
        .map((t) => {
              'name': t['name'].toString(),
              'description': t['description'].toString(),
            })
        .toList();
  }
}

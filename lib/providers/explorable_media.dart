import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/models/tuple.dart';

class ExplorableMedia with ChangeNotifier {
  static const String _url = 'https://graphql.anilist.co';
  Map<String, String> _headers;

  void init(Map<String, String> headers) {
    _headers = headers;
  }

  List<Map<String, dynamic>> _data;
  List<String> _genres;
  List<Tuple<String, String>> _tags;
  Map<String, dynamic> _filters = {
    'page': 1,
    'perPage': 30,
    'type': 'ANIME',
    'sort': describeEnum(MediaSort.TRENDING_DESC),
    'id_not_in': [],
  };

  String get searchValue {
    return _filters['search'];
  }

  List<Map<String, dynamic>> get data {
    return [..._data];
  }

  List<String> get genres {
    return [..._genres];
  }

  List<String> get genreIn {
    if (_filters.containsKey('genre_in')) {
      return [..._filters['genre_in']];
    }
    return [];
  }

  List<String> get genreNotIn {
    if (_filters.containsKey('genre_not_in')) {
      return [..._filters['genre_not_in']];
    }
    return [];
  }

  List<Tuple<String, String>> get tags {
    return [..._tags];
  }

  List<String> get tagIn {
    if (_filters.containsKey('tag_in')) {
      return [..._filters['tag_in']];
    }
    return [];
  }

  List<String> get tagNotIn {
    if (_filters.containsKey('tag_not_int')) {
      return [..._filters['tag_not_in']];
    }
    return [];
  }

  Future<void> fetchFilters() async {
    final request = json.encode({
      'query': r'''
        query Filters {
          GenreCollection
          MediaTagCollection {
            name
            description
          }
        }
      ''',
    });

    final response = await post(_url, body: request, headers: _headers);
    final body = json.decode(response.body)['data'];

    _genres = (body['GenreCollection'] as List<dynamic>)
        .map((g) => g.toString())
        .toList();

    _tags = (body['MediaTagCollection'] as List<dynamic>)
        .map((t) => Tuple(t['name'], t['description']))
        .toList();

    notifyListeners();
  }

  void setGenreTagFilters({
    List<String> newGenreIn,
    List<String> newGenreNotIn,
    List<String> newTagIn,
    List<String> newTagNotIn,
    bool addPageAndNotReset,
  }) {
    if (newGenreIn.length == 0) {
      _filters.remove('genre_in');
    } else {
      _filters['genre_in'] = newGenreIn;
    }

    if (newGenreNotIn.length == 0) {
      _filters.remove('genre_not_in');
    } else {
      _filters['genre_not_in'] = newGenreNotIn;
    }

    if (newTagIn.length == 0) {
      _filters.remove('tag_in');
    } else {
      _filters['tag_in'] = newTagIn;
    }

    if (newTagNotIn.length == 0) {
      _filters.remove('tag_not_in');
    } else {
      _filters['tag_not_in'] = newTagNotIn;
    }
    fetchMedia();
  }

  void searchValue(String searchValue) {
    if (searchValue == _filters['search']) return;

    if (searchValue == null || searchValue == '') {
      _filters.remove('search');
    } else {
      _filters['search'] = searchValue;
    }
    fetchMedia();
  }

  void pagination(bool addButNotReset) {
    if (addButNotReset) {
      _filters['page']++;
    } else {
      _filters['page'] = 1;
    }
    fetchMedia();
  }

  Future<void> fetchMedia() async {
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
      'variables': _filters,
    });

    final response = await post(_url, body: request, headers: _headers);

    final body = json.decode(response.body) as Map<String, dynamic>;

    _data = (body['data']['Page']['media'] as List<dynamic>)
        .map((m) => {
              'title': m['title']['userPreferred'],
              'imageUrl': m['coverImage']['large'],
              'id': m['id'],
            })
        .toList();

    notifyListeners();
  }
}

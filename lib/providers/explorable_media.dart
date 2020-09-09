import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/media_group_provider.dart';

//Manages all browsable media, genres, tags and all the filters
class ExplorableMedia with ChangeNotifier implements MediaGroupProvider {
  static const String _url = 'https://graphql.anilist.co';
  Map<String, String> _headers;

  void init(Map<String, String> headers) {
    _headers = headers;
  }

  bool _isLoading = false;
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

  @override
  String get search {
    return _filters['search'];
  }

  @override
  set search(String searchValue) {
    if (searchValue == _filters['search']) return;

    if (searchValue == null || searchValue == '') {
      _filters.remove('search');
    } else {
      _filters['search'] = searchValue;
    }
    fetchMedia();
  }

  String get sort {
    return _filters['sort'];
  }

  set sort(String mediaSort) {
    _filters['sort'] = mediaSort;
    fetchMedia();
  }

  String get type {
    return _filters['type'];
  }

  set type(String type) {
    _filters['type'] = type;
    fetchMedia();
  }

  @override
  bool get isLoading {
    return _isLoading;
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

  void setGenreTagFilters({
    List<String> newGenreIn,
    List<String> newGenreNotIn,
    List<String> newTagIn,
    List<String> newTagNotIn,
    bool addPageAndNotReset,
  }) {
    if (newGenreIn != null && newGenreIn.length == 0) {
      _filters.remove('genre_in');
    } else {
      _filters['genre_in'] = newGenreIn;
    }

    if (newGenreNotIn != null && newGenreNotIn.length == 0) {
      _filters.remove('genre_not_in');
    } else {
      _filters['genre_not_in'] = newGenreNotIn;
    }

    if (newTagIn != null && newTagIn.length == 0) {
      _filters.remove('tag_in');
    } else {
      _filters['tag_in'] = newTagIn;
    }

    if (newTagNotIn != null && newTagNotIn.length == 0) {
      _filters.remove('tag_not_in');
    } else {
      _filters['tag_not_in'] = newTagNotIn;
    }
    fetchMedia();
  }

  bool areFiltersActive() {
    return _filters.containsKey('genre_in') ||
        _filters.containsKey('genre_not_in') ||
        _filters.containsKey('tag_in') ||
        _filters.containsKey('tag_not_in');
  }

  void clearGenreTagFilters() {
    _filters.remove('genre_in');
    _filters.remove('genre_not_in');
    _filters.remove('tag_in');
    _filters.remove('tag_not_in');
    fetchMedia();
  }

  @override
  void clear() {
    _filters.remove('genre_in');
    _filters.remove('genre_not_in');
    _filters.remove('tag_in');
    _filters.remove('tag_not_in');
    _filters.remove('search');
    fetchMedia();
  }

  void addPage() {
    _filters['page']++;
    fetchMedia(clean: false);
  }

  //Fetches meida based on the set filters
  @override
  Future<void> fetchMedia({bool clean = true}) async {
    _isLoading = true;
    if (_data != null) notifyListeners();

    if (clean) {
      _filters['id_not_in'] = [];
      _filters['page'] = 1;
    }

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

    if (clean) _data = [];

    for (final m in body['data']['Page']['media'] as List<dynamic>) {
      _data.add({
        'title': m['title']['userPreferred'],
        'imageUrl': m['coverImage']['large'],
        'id': m['id'],
      });
      (_filters['id_not_in'] as List<dynamic>).add(m['id']);
    }

    _isLoading = false;
    notifyListeners();
  }

  //Fetches genres and tags
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
        .map((t) => Tuple(t['name'].toString(), t['description'].toString()))
        .toList();

    notifyListeners();
  }
}

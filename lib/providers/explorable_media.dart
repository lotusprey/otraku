import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/media_group_provider.dart';

//Manages all browsable media, genres, tags and all the filters
class ExplorableMedia with ChangeNotifier implements MediaGroupProvider {
  static const KEY_STATUS_IN = 'status_in';
  static const KEY_STATUS_NOT_IN = 'status_not_in';
  static const KEY_FORMAT_IN = 'format_in';
  static const KEY_FORMAT_NOT_IN = 'format_not_in';
  static const KEY_ID_NOT_IN = 'id_not_in';
  static const KEY_GENRE_IN = 'genre_in';
  static const KEY_GENRE_NOT_IN = 'genre_not_in';
  static const KEY_TAG_IN = 'tag_in';
  static const KEY_TAG_NOT_IN = 'tag_not_in';

  static const String _url = 'https://graphql.anilist.co';
  Map<String, String> _headers;

  void init(Map<String, String> headers) {
    _headers = headers;
  }

  bool _isLoading = false;
  List<Map<String, dynamic>> _data;
  List<String> _genres;
  Tuple<List<String>, List<String>> _tags;
  Map<String, dynamic> _filters = {
    'page': 1,
    'perPage': 30,
    'type': 'ANIME',
    'sort': describeEnum(MediaSort.TRENDING_DESC),
    KEY_ID_NOT_IN: [],
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
    _filters.remove(KEY_FORMAT_IN);
    _filters.remove(KEY_FORMAT_NOT_IN);
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

  Tuple<List<String>, List<String>> get tags {
    return _tags;
  }

  List<String> getFilterWithKey(String key) {
    if (_filters.containsKey(key)) {
      return [..._filters[key]];
    }
    return [];
  }

  void setGenreTagFilters({
    List<String> newStatusIn,
    List<String> newStatusNotIn,
    List<String> newFormatIn,
    List<String> newFormatNotIn,
    List<String> newGenreIn,
    List<String> newGenreNotIn,
    List<String> newTagIn,
    List<String> newTagNotIn,
  }) {
    if (newStatusIn != null && newStatusIn.length == 0) {
      _filters.remove(KEY_STATUS_IN);
    } else {
      _filters[KEY_STATUS_IN] = newStatusIn;
    }

    if (newStatusNotIn != null && newStatusNotIn.length == 0) {
      _filters.remove(KEY_STATUS_NOT_IN);
    } else {
      _filters[KEY_STATUS_NOT_IN] = newStatusNotIn;
    }

    if (newFormatIn != null && newFormatIn.length == 0) {
      _filters.remove(KEY_FORMAT_IN);
    } else {
      _filters[KEY_FORMAT_IN] = newFormatIn;
    }

    if (newFormatNotIn != null && newFormatNotIn.length == 0) {
      _filters.remove(KEY_FORMAT_NOT_IN);
    } else {
      _filters[KEY_FORMAT_NOT_IN] = newFormatNotIn;
    }

    if (newGenreIn != null && newGenreIn.length == 0) {
      _filters.remove(KEY_GENRE_IN);
    } else {
      _filters[KEY_GENRE_IN] = newGenreIn;
    }

    if (newGenreNotIn != null && newGenreNotIn.length == 0) {
      _filters.remove(KEY_GENRE_NOT_IN);
    } else {
      _filters[KEY_GENRE_NOT_IN] = newGenreNotIn;
    }

    if (newTagIn != null && newTagIn.length == 0) {
      _filters.remove(KEY_TAG_IN);
    } else {
      _filters[KEY_TAG_IN] = newTagIn;
    }

    if (newTagNotIn != null && newTagNotIn.length == 0) {
      _filters.remove(KEY_TAG_NOT_IN);
    } else {
      _filters[KEY_TAG_NOT_IN] = newTagNotIn;
    }
    fetchMedia();
  }

  bool areFiltersActive() {
    return _filters.containsKey(KEY_STATUS_IN) ||
        _filters.containsKey(KEY_STATUS_NOT_IN) ||
        _filters.containsKey(KEY_FORMAT_IN) ||
        _filters.containsKey(KEY_FORMAT_NOT_IN) ||
        _filters.containsKey(KEY_GENRE_IN) ||
        _filters.containsKey(KEY_GENRE_NOT_IN) ||
        _filters.containsKey(KEY_TAG_IN) ||
        _filters.containsKey(KEY_TAG_NOT_IN);
  }

  void clearGenreTagFilters({bool fetch = true}) {
    _filters.remove(KEY_STATUS_IN);
    _filters.remove(KEY_STATUS_NOT_IN);
    _filters.remove(KEY_FORMAT_IN);
    _filters.remove(KEY_FORMAT_NOT_IN);
    _filters.remove(KEY_GENRE_IN);
    _filters.remove(KEY_GENRE_NOT_IN);
    _filters.remove(KEY_TAG_IN);
    _filters.remove(KEY_TAG_NOT_IN);
    if (fetch) fetchMedia();
  }

  @override
  void clear() {
    clearGenreTagFilters(fetch: false);
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
      _filters[KEY_ID_NOT_IN] = [];
      _filters['page'] = 1;
    }

    final query = '''
      query Browse(\$page: Int, \$perPage: Int, \$id_not_in: [Int], 
          \$sort: [MediaSort], \$type: MediaType, \$search: String,
          ${_filters.containsKey(KEY_STATUS_IN) ? '\$status_in: [MediaStatus],' : ''}
          ${_filters.containsKey(KEY_STATUS_NOT_IN) ? '\$status_not_in: [MediaStatus],' : ''}
          ${_filters.containsKey(KEY_FORMAT_IN) ? '\$format_in: [MediaFormat],' : ''}
          ${_filters.containsKey(KEY_FORMAT_NOT_IN) ? '\$format_not_in: [MediaFormat],' : ''}
          \$genre_in: [String], \$genre_not_in: [String], \$tag_in: [String], 
          \$tag_not_in: [String]) {
        Page(page: \$page, perPage: \$perPage) {
          media(id_not_in: \$id_not_in, sort: \$sort, type: \$type, 
          search: \$search,
          ${_filters.containsKey(KEY_STATUS_IN) ? 'status_in: \$status_in,' : ''}
          ${_filters.containsKey(KEY_STATUS_NOT_IN) ? 'status_not_in: \$status_not_in,' : ''}
          ${_filters.containsKey(KEY_FORMAT_IN) ? 'format_in: \$format_in,' : ''}
          ${_filters.containsKey(KEY_FORMAT_NOT_IN) ? 'format_not_in: \$format_not_in,' : ''}
          genre_in: \$genre_in, genre_not_in: \$genre_not_in, 
          tag_in: \$tag_in, tag_not_in: \$tag_not_in) {
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
      (_filters[KEY_ID_NOT_IN] as List<dynamic>).add(m['id']);
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

    _tags = Tuple([], []);
    for (final tag in body['MediaTagCollection']) {
      _tags.item1.add(tag['name']);
      _tags.item2.add(tag['description']);
    }

    notifyListeners();
  }
}

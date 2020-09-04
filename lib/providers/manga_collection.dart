import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/list_entry_media_data.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/collection.dart';

class MangaCollection extends Collection with ChangeNotifier {
  //Query settings
  static const String _url = 'https://graphql.anilist.co';
  Map<String, String> _headers;
  int _userId;
  String _scoreFormat;
  MediaListSort _mediaListSort;

  //Information passed by the Auth provider
  void init({
    @required Map<String, String> headers,
    @required int userId,
    @required String scoreFormat,
    @required MediaListSort mediaListSort,
  }) {
    _headers = headers;
    _userId = userId;
    _scoreFormat = scoreFormat;
    _mediaListSort = mediaListSort;
  }

  //Data
  bool _isLoading = false;
  List<String> _names = [];
  List<List<ListEntryMediaData>> _entryLists = [];
  int _listIndex = -1;
  String _search = '';

  @override
  MediaListSort get sort {
    return _mediaListSort;
  }

  @override
  set sort(MediaListSort value) {
    _mediaListSort = value;
  }

  @override
  String get collectionName {
    return 'Manga';
  }

  @override
  List<String> get names {
    return [..._names];
  }

  @override
  bool get isLoading {
    return _isLoading;
  }

  @override
  bool get isEmpty {
    return !_isLoading && _names.length == 0;
  }

  @override
  String get search {
    return _search;
  }

  ///Configure the list index and search filters
  void setFilters({listIndex, search}) {
    if (listIndex != null && listIndex >= -1 && listIndex < _names.length) {
      _listIndex = listIndex;
    }

    if (search != null) {
      _search = search;
    }

    notifyListeners();
  }

  //Returns filtered lists
  Tuple<List<String>, List<List<ListEntryMediaData>>> lists() {
    if (_listIndex == -1) {
      if (_search == '') {
        return Tuple([..._names], [..._entryLists]);
      }

      List<List<ListEntryMediaData>> currentEntries = [];
      List<String> currentNames = [];
      for (int i = 0; i < _names.length; i++) {
        List<ListEntryMediaData> sublist = [];
        for (ListEntryMediaData entry in _entryLists[i]) {
          if (entry.title.toLowerCase().contains(_search)) {
            sublist.add(entry);
          }
        }

        if (sublist.length > 0) {
          currentEntries.add(sublist);
          currentNames.add(_names[i]);
        }
      }

      if (currentEntries.length == 0) {
        return null;
      }

      return Tuple([...currentNames], [...currentEntries]);
    }

    if (_search == '') {
      return Tuple([
        ...[_names[_listIndex]]
      ], [
        ...[_entryLists[_listIndex]]
      ]);
    }

    List<ListEntryMediaData> currentEntries = [];
    for (ListEntryMediaData entry in _entryLists[_listIndex]) {
      if (entry.title.toLowerCase().contains(_search)) {
        currentEntries.add(entry);
      }
    }

    if (currentEntries.length == 0) {
      return null;
    }

    return Tuple([
      ...[_names[_listIndex]]
    ], [
      ...[currentEntries]
    ]);
  }

  //Fetch anime media list collection
  @override
  Future<void> fetchMediaListCollection() async {
    _isLoading = true;

    const query = r'''
      query Collection($userId: Int, $sort: [MediaListSort], $scoreFormat: ScoreFormat) {
        MediaListCollection(userId: $userId, type: MANGA, sort: $sort) {
          lists {
            name
            entries {
              mediaId
              progress
              score(format: $scoreFormat)
              media {
                format
                chapters
                title {
                  userPreferred
                }
                coverImage {
                  medium
                }
              }
            }
          }
        }
        User(id: $userId) {
          mediaListOptions {
            mangaList {
              sectionOrder
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {
        'userId': _userId,
        'scoreFormat': _scoreFormat,
        'sort': describeEnum(_mediaListSort),
      },
    });

    final response = await post(_url, body: request, headers: _headers);
    final result = json.decode(response.body)['data'];

    final mediaListCollection =
        result['MediaListCollection']['lists'] as List<dynamic>;

    final sectionOrder = result['User']['mediaListOptions']['mangaList']
        ['sectionOrder'] as List<dynamic>;

    _names = [];
    _entryLists = [];

    for (final section in sectionOrder) {
      for (int i = 0; i < mediaListCollection.length; i++) {
        if (section == mediaListCollection[i]['name']) {
          final currentMediaList = mediaListCollection.removeAt(i);

          _names.add(currentMediaList['name']);

          _entryLists.add((currentMediaList['entries'] as List<dynamic>)
              .map((e) => ListEntryMediaData(
                    id: e['mediaId'],
                    title: e['media']['title']['userPreferred'],
                    cover: e['media']['coverImage']['medium'],
                    format: e['media']['format'],
                    score: e['score'].toDouble(),
                    progress: e['progress'],
                    totalEpCount: (e['media']['chapters'] ?? '?').toString(),
                  ))
              .toList());

          break;
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> removeFromList(int id) {
    return null;
  }
}

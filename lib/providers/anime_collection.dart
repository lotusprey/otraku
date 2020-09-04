import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/list_entry_media_data.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/collection.dart';

class AnimeCollection extends Collection with ChangeNotifier {
  //Query settings
  static const String _url = 'https://graphql.anilist.co';
  Map<String, String> _headers;
  int _userId;
  String _scoreFormat;
  MediaListSort _mediaListSort;

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

  @override
  MediaListSort get sort {
    return _mediaListSort;
  }

  @override
  set sort(MediaListSort value) {
    _mediaListSort = value;
  }

  @override
  String get name {
    return 'Anime';
  }

  @override
  bool get isLoading {
    return _isLoading;
  }

  @override
  bool get isEmpty {
    return !_isLoading && _names.length == 0;
  }

  Tuple<List<String>, List<List<ListEntryMediaData>>> lists({
    int listIndex = -1,
    String search,
  }) {
    if (listIndex == -1) {
      if (search == null) {
        return Tuple(_names, _entryLists);
      }

      List<List<ListEntryMediaData>> currentEntries = [];
      List<String> currentNames = [];
      for (int i = 0; i < _names.length; i++) {
        List<ListEntryMediaData> sublist = [];
        for (ListEntryMediaData entry in _entryLists[i]) {
          if (entry.title.toLowerCase().contains(search)) {
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

      return Tuple(currentNames, currentEntries);
    }

    if (search == null) {
      return Tuple([_names[listIndex]], [_entryLists[listIndex]]);
    }

    List<ListEntryMediaData> currentEntries = [];
    for (ListEntryMediaData entry in _entryLists[listIndex]) {
      if (entry.title.toLowerCase().contains(search)) {
        currentEntries.add(entry);
      }
    }

    if (currentEntries.length == 0) {
      return null;
    }

    return Tuple([_names[listIndex]], [currentEntries]);
  }

  //Fetch anime media list collection
  @override
  Future<void> fetchMediaListCollection() async {
    _isLoading = true;

    const query = r'''
      query Collection($userId: Int, $sort: [MediaListSort], $scoreFormat: ScoreFormat) {
        MediaListCollection(userId: $userId, type: ANIME, sort: $sort) {
          lists {
            name
            entries {
              mediaId
              progress
              score(format: $scoreFormat)
              media {
                format
                episodes
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
            animeList {
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

    final sectionOrder = result['User']['mediaListOptions']['animeList']
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
                    totalEpCount: (e['media']['episodes'] ?? '?').toString(),
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

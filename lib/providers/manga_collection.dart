import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/list_entry_media.dart';
import 'package:otraku/models/list_entry_user_data.dart';
import 'package:otraku/providers/collection_provider.dart';

//Manages the users manga collection of lists
class MangaCollection with ChangeNotifier implements CollectionProvider {
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
  List<String> _names;
  List<List<ListEntryMedia>> _entryLists;
  int _listIndex = 0;
  String _search;

  @override
  String get search {
    return _search;
  }

  @override
  set search(String value) {
    if (value != _search) {
      _search = value;
      notifyListeners();
    }
  }

  @override
  int get listIndex {
    return _listIndex;
  }

  @override
  set listIndex(int index) {
    if (index != null && index >= 0 && index < _names.length) {
      _listIndex = index;
      notifyListeners();
    }
  }

  @override
  MediaListSort get sort {
    return _mediaListSort;
  }

  @override
  set sort(MediaListSort value) {
    if (value != null) _mediaListSort = value;
  }

  @override
  String get collectionName {
    return 'Manga';
  }

  @override
  bool get isAnimeCollection {
    return false;
  }

  @override
  List<String> get names {
    if (_names == null || _names.length == 0) {
      return null;
    }
    return [..._names];
  }

  @override
  List<ListEntryMedia> get entries {
    if (_search == null) {
      return _entryLists[_listIndex];
    }

    List<ListEntryMedia> currentEntries = [];
    for (ListEntryMedia entry in _entryLists[_listIndex]) {
      if (entry.title.toLowerCase().contains(_search)) {
        currentEntries.add(entry);
      }
    }

    if (currentEntries.length == 0) {
      return null;
    }

    return currentEntries;
  }

  @override
  bool get isLoading {
    return _isLoading;
  }

  @override
  bool get isEmpty {
    return !_isLoading && names == null;
  }

  @override
  void clear() {
    _listIndex = 0;
    _search = null;
    fetchMedia();
  }

  //Fetch anime media list collection
  @override
  Future<void> fetchMedia() async {
    _isLoading = true;

    if (_names != null) notifyListeners();

    const query = r'''
      query Collection($userId: Int, $scoreFormat: ScoreFormat) {
        MediaListCollection(userId: $userId, type: MANGA, sort: SCORE_DESC) {
          lists {
            name
            entries {
              mediaId
              status
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
              .map((e) => ListEntryMedia(
                    id: e['mediaId'],
                    title: e['media']['title']['userPreferred'],
                    cover: e['media']['coverImage']['medium'],
                    format: e['media']['format'],
                    progressMaxString:
                        (e['media']['episodes'] ?? '?').toString(),
                    userData: ListEntryUserData(
                      mediaListStatus: stringToEnum(
                          e['status'],
                          Map.fromIterable(
                            MediaListSort.values,
                            key: (element) => describeEnum(element),
                            value: (element) => element,
                          )),
                      progress: e['progress'],
                      progressMax: e['media']['episodes'],
                      score: e['score'].toDouble(),
                    ),
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
  void sortCollection() {
    for (int i = 0; i < _entryLists.length; i++) {
      sortList(i);
    }
    notifyListeners();
  }

  @override
  void sortList(int index) {
    switch (_mediaListSort) {
      case MediaListSort.TITLE:
        _entryLists[index].sort((a, b) => a.title.compareTo(b.title));
        break;
      case MediaListSort.TITLE_DESC:
        _entryLists[index].sort((a, b) => b.title.compareTo(a.title));
        break;
      case MediaListSort.SCORE:
        _entryLists[index]
            .sort((a, b) => a.userData.score.compareTo(b.userData.score));
        break;
      case MediaListSort.SCORE_DESC:
        _entryLists[index]
            .sort((a, b) => b.userData.score.compareTo(a.userData.score));
        break;
      default:
        break;
    }
  }
}

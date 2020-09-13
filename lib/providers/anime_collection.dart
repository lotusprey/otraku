import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/entry_list.dart';
import 'package:otraku/models/media_entry.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/collection_provider.dart';

//Manages the users anime collection of lists
class AnimeCollection with ChangeNotifier implements CollectionProvider {
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
  List<EntryList> _lists;
  bool _isLoading = false;
  int _listIndex = 0;
  String _search;

  @override
  String get collectionName {
    return 'Anime';
  }

  @override
  bool get isAnimeCollection {
    return true;
  }

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
    if (index != null && index >= 0 && index < _lists.length) {
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
  List<String> get names {
    if (_lists == null || _lists.length == 0) {
      return null;
    }
    return [..._lists.map((l) => l.name).toList()];
  }

  @override
  List<MediaEntry> get entries {
    if (_search == null) {
      return _lists[_listIndex].entries;
    }

    List<MediaEntry> currentEntries = [];
    for (MediaEntry entry in _lists[_listIndex].entries) {
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

    if (_lists != null) notifyListeners();

    const query = r'''
      query Collection($userId: Int, $scoreFormat: ScoreFormat) {
        MediaListCollection(userId: $userId, type: ANIME, sort: SCORE_DESC) {
          lists {
            name
            status
            isSplitCompletedList
            entries {
              mediaId
              status
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
      },
    });

    final response = await post(_url, body: request, headers: _headers);
    final result = json.decode(response.body)['data'];

    final mediaListCollection =
        result['MediaListCollection']['lists'] as List<dynamic>;

    final sectionOrder = result['User']['mediaListOptions']['animeList']
        ['sectionOrder'] as List<dynamic>;

    _lists = [];

    for (final section in sectionOrder) {
      for (int i = 0; i < mediaListCollection.length; i++) {
        if (section == mediaListCollection[i]['name']) {
          final currentMediaList = mediaListCollection.removeAt(i);

          _lists.add(EntryList(
            name: currentMediaList['name'],
            status: currentMediaList['status'],
            isSplitCompletedList: currentMediaList['isSplitCompletedList'],
            entries: (currentMediaList['entries'] as List<dynamic>)
                .map((e) => MediaEntry(
                      mediaId: e['mediaId'],
                      title: e['media']['title']['userPreferred'],
                      cover: e['media']['coverImage']['medium'],
                      format: e['media']['format'],
                      progressMaxString:
                          (e['media']['episodes'] ?? '?').toString(),
                      entryUserData: EntryUserData(
                        mediaId: e['mediaId'],
                        progress: e['progress'],
                        progressMax: e['media']['episodes'],
                        score: e['score'].toDouble(),
                      ),
                    ))
                .toList(),
          ));

          break;
        }
      }
    }

    _isLoading = false;
    sortCollection();
  }

  @override
  void sortCollection() {
    for (int i = 0; i < _lists.length; i++) {
      sortList(i);
    }
    notifyListeners();
  }

  @override
  void sortList(int index) {
    switch (_mediaListSort) {
      case MediaListSort.TITLE:
        _lists[index].entries.sort((a, b) => a.title.compareTo(b.title));
        break;
      case MediaListSort.TITLE_DESC:
        _lists[index].entries.sort((a, b) => b.title.compareTo(a.title));
        break;
      case MediaListSort.SCORE:
        _lists[index].entries.sort((a, b) {
          int comparison = a.userData.score.compareTo(b.userData.score);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        });
        break;
      case MediaListSort.SCORE_DESC:
        _lists[index].entries.sort((a, b) {
          int comparison = b.userData.score.compareTo(a.userData.score);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        });
        break;
      default:
        break;
    }
  }

  @override
  Future<bool> updateEntry(EntryUserData oldData, EntryUserData newData) async {
    final updatable = oldData.entryId != null;

    final query = '''
      mutation Update(
        ${updatable ? '\$id: Int' : ''}
        \$mediaId: Int
        \$status: MediaListStatus
        \$scoreFormat: ScoreFormat
      ) {
      SaveMediaListEntry(
        ${updatable ? 'id: \$id' : ''}
        mediaId: \$mediaId, 
        status: \$status) {
          id
          mediaId
          status
          progress
          score(format: \$scoreFormat)
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
    ''';

    final request = json.encode({
      'query': query,
      'variables': {
        'id': newData.entryId,
        'mediaId': newData.mediaId,
        'status': describeEnum(newData.status),
        'scoreFormat': _scoreFormat,
      },
    });

    final result = await post(_url, body: request, headers: _headers);

    final entryData =
        (json.decode(result.body) as Map<String, dynamic>)['data'];

    if (entryData == null) return false;

    final data = entryData['SaveMediaListEntry'];

    MediaEntry entry = MediaEntry(
      mediaId: data['mediaId'],
      title: data['media']['title']['userPreferred'],
      cover: data['media']['coverImage']['medium'],
      format: data['media']['format'],
      progressMaxString: (data['media']['episodes'] ?? '?').toString(),
      entryUserData: EntryUserData(
        mediaId: data['mediaId'],
        progress: data['progress'],
        progressMax: data['media']['episodes'],
        score: data['score'].toDouble(),
      ),
    );

    if (updatable) {
      int oldListIndex;
      for (int i = 0; i < _lists.length; i++) {
        if (_lists[i].status == describeEnum(oldData.status)) {
          oldListIndex = i;
          break;
        }
      }

      for (final e in _lists[oldListIndex].entries) {
        if (e.mediaId == entry.mediaId) {
          _lists[oldListIndex].entries.remove(e);
          break;
        }
      }

      if (oldData.status == entry.userData.status) {
        _lists[oldListIndex].entries.add(entry);
        sortList(oldListIndex);
      }
    }

    if (!updatable || oldData.status != entry.userData.status) {
      for (int i = 0; i < _lists.length; i++) {
        if (_lists[i].status == describeEnum(newData.status)) {
          _lists[i].entries.add(entry);
          sortList(i);
          break;
        }
      }
    }

    notifyListeners();
    return true;
  }
}

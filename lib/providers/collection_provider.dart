import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/entry_list.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/models/media_entry.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/media_group_provider.dart';

class CollectionProvider with ChangeNotifier implements MediaGroupProvider {
  static const String _url = 'https://graphql.anilist.co';
  static Map<String, String> _headers;
  static int _userId;
  static String _scoreFormat;
  static MediaListSort _mediaListSort;

  final bool isAnime;
  final String typeUCase;
  final String typeLCase;
  final String mediaParts;

  CollectionProvider({
    @required this.isAnime,
    @required this.typeUCase,
    @required this.typeLCase,
    @required this.mediaParts,
  });

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
  List<EntryList> _lists;
  int _listIndex = 0;
  String _search;

  //Getters and Setters

  String get collectionName {
    if (isAnime) return 'Anime';
    return 'Manga';
  }

  bool get isEmpty {
    return !_isLoading && (_lists == null || _lists.length == 0);
  }

  @override
  bool get isLoading {
    return _isLoading;
  }

  List<String> get names {
    if (_lists == null || _lists.length == 0) {
      return null;
    }
    return [..._lists.map((l) => l.name).toList()];
  }

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

  MediaListSort get sort {
    return _mediaListSort;
  }

  set sort(MediaListSort value) {
    if (value != null) _mediaListSort = value;
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

  int get listIndex {
    return _listIndex;
  }

  set listIndex(int index) {
    if (index != null && index >= 0 && index < _lists.length) {
      _listIndex = index;
      notifyListeners();
    }
  }

  //Methods

  //Clear the filters and fetch the collection again.
  @override
  void clear() {
    _listIndex = 0;
    _search = null;
    fetchMedia();
  }

  //Fetches media list collection.
  @override
  Future<void> fetchMedia() async {
    _isLoading = true;

    if (_lists != null) notifyListeners();

    final tuple = await fetchLists();
    final mediaListCollection = tuple.item1;
    final sectionOrder = tuple.item2;

    _lists = [];

    for (final section in sectionOrder) {
      for (int i = 0; i < mediaListCollection.length; i++) {
        if (section == mediaListCollection[i]['name']) {
          final currentMediaList = mediaListCollection.removeAt(i);

          _lists.add(EntryList(
            name: currentMediaList['name'],
            status: currentMediaList['status'],
            isCustomList: currentMediaList['isCustomList'],
            isSplitCompletedList: currentMediaList['isSplitCompletedList'],
            entries: (currentMediaList['entries'] as List<dynamic>)
                .map((e) => MediaEntry(
                      mediaId: e['mediaId'],
                      title: e['media']['title']['userPreferred'],
                      cover: e['media']['coverImage']['medium'],
                      format: e['media']['format'],
                      progressMaxString:
                          (e['media'][mediaParts] ?? '?').toString(),
                      entryUserData: EntryUserData(
                        mediaId: e['mediaId'],
                        type: typeUCase,
                        progress: e['progress'],
                        progressMax: e['media'][mediaParts],
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

  //Sorts all lists.
  void sortCollection() {
    for (int i = 0; i < _lists.length; i++) {
      sortList(i);
    }
    notifyListeners();
  }

  //Sorts a list at a given index.
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

  //Updates entry data and its corresponding lists.
  //Returns true if it was successful and false if it wasn't.
  Future<bool> updateEntry(EntryUserData oldData, EntryUserData newData) async {
    //Determine if the entry is newly added or an old one.
    final alreadyAdded = oldData.entryId != null;

    //Update the entry.
    final query = '''
      mutation Update(
        ${alreadyAdded ? '\$id: Int' : ''}
        \$mediaId: Int
        \$status: MediaListStatus
        \$scoreFormat: ScoreFormat
      ) {
      SaveMediaListEntry(
        ${alreadyAdded ? 'id: \$id' : ''}
        mediaId: \$mediaId, 
        status: \$status) {
          id
          mediaId
          status
          progress
          score(format: \$scoreFormat)
          media {
            format
            $mediaParts
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

    //Check if the operation was successful
    if (entryData == null) return false;

    //Remove the entry from the previous list if it existed before.
    if (alreadyAdded) {
      for (int i = 0; i < _lists.length; i++) {
        if (_lists[i].status == describeEnum(oldData.status)) {
          for (final e in _lists[i].entries) {
            if (e.mediaId == newData.mediaId) {
              _lists[i].entries.remove(e);
              if (_lists[i].entries.length == 0) {
                _lists.removeAt(i);
                if (_listIndex > 0 && _listIndex >= _lists.length) {
                  _listIndex = _lists.length - 1;
                }
              }
              break;
            }
          }
          break;
        }
      }
    }

    //Check if the list to which it was added exists locally.
    int newListIndex;
    for (int i = 0; i < _lists.length; i++) {
      if (_lists[i].status == describeEnum(newData.status)) {
        newListIndex = i;
        break;
      }
    }

    //If the list isn't available locally, fetch it. Otherwise,
    //find it and add the updated entry.
    if (newListIndex == null) {
      await fetchSingleList(describeEnum(newData.status));
    } else {
      final data = entryData['SaveMediaListEntry'];

      for (int i = 0; i < _lists.length; i++) {
        if (_lists[i].status == describeEnum(newData.status)) {
          _lists[i].entries.add(MediaEntry(
                mediaId: data['mediaId'],
                title: data['media']['title']['userPreferred'],
                cover: data['media']['coverImage']['medium'],
                format: data['media']['format'],
                progressMaxString:
                    (data['media'][mediaParts] ?? '?').toString(),
                entryUserData: EntryUserData(
                  mediaId: data['mediaId'],
                  type: typeUCase,
                  progress: data['progress'],
                  progressMax: data['media'][mediaParts],
                  score: data['score'].toDouble(),
                ),
              ));
          sortList(i);
          break;
        }
      }
    }

    notifyListeners();
    return true;
  }

  //Removes the entry from all lists.
  //Returns true if it was successful and false if it wasn't.
  Future<bool> removeEntry(EntryUserData data) async {
    //Remove the entry
    final query = r'''
      mutation Remove($id: Int) {
        DeleteMediaListEntry(id: $id) {
          deleted
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {
        'id': data.entryId,
      },
    });

    final response = await post(_url, body: request, headers: _headers);
    final body = json.decode(response.body)['data'];

    //Check if the operation was successful
    if (body['deleted'] == false) return false;

    //Remove the entry from the lists where it occured
    for (final list in _lists) {
      if (list.status == describeEnum(data.status) ||
          (list.status == null && data.customLists.contains(list.name))) {
        for (final e in list.entries) {
          if (e.mediaId == data.mediaId) {
            list.entries.remove(e);
            if (list.entries.length == 0) {
              _lists.remove(list);
              if (_listIndex > 0 && _listIndex >= _lists.length) {
                _listIndex = _lists.length - 1;
              }
            }
            break;
          }
        }
      }
    }

    notifyListeners();
    return true;
  }

  //Fetches a list collection.
  Future<Tuple<List<dynamic>, List<dynamic>>> fetchLists(
      {String status}) async {
    final query = '''
      query Collection(
          \$userId: Int, ${status != null ? '\$status: MediaListStatus,' : ''} 
          \$scoreFormat: ScoreFormat) {
        MediaListCollection(
            userId: \$userId, ${status != null ? 'status: \$status,' : ''} 
            type: $typeUCase, sort: SCORE_DESC) {
          lists {
            name
            status
            isCustomList
            isSplitCompletedList
            entries {
              mediaId
              status
              progress
              score(format: \$scoreFormat)
              media {
                format
                $mediaParts
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
        User(id: \$userId) {
          mediaListOptions {
            ${typeLCase}List {
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
        'status': status,
        'scoreFormat': _scoreFormat,
      },
    });

    final response = await post(_url, body: request, headers: _headers);
    final result = json.decode(response.body)['data'];

    return Tuple(
      result['MediaListCollection']['lists'],
      result['User']['mediaListOptions']['${typeLCase}List']['sectionOrder'],
    );
  }

  //Fetches a single list with a given status and add it.
  Future<void> fetchSingleList(String status) async {
    final tuple = await fetchLists(status: status);
    final listData = tuple.item1[0];
    final sectionOrder = tuple.item2;

    final list = EntryList(
      name: listData['name'],
      status: listData['status'],
      isCustomList: listData['isCustomList'],
      isSplitCompletedList: listData['isSplitCompletedList'],
      entries: (listData['entries'] as List<dynamic>)
          .map((e) => MediaEntry(
                mediaId: e['mediaId'],
                title: e['media']['title']['userPreferred'],
                cover: e['media']['coverImage']['medium'],
                format: e['media']['format'],
                progressMaxString: (e['media'][mediaParts] ?? '?').toString(),
                entryUserData: EntryUserData(
                  mediaId: e['mediaId'],
                  type: typeUCase,
                  progress: e['progress'],
                  progressMax: e['media'][mediaParts],
                  score: e['score'].toDouble(),
                ),
              ))
          .toList(),
    );

    for (int i = 0; i < sectionOrder.length; i++) {
      if (sectionOrder[i] == list.name) {
        if (sectionOrder.length == _lists.length) {
          _lists[i] = list;
        } else {
          _lists.insert(i, list);
          if (_listIndex >= i) _listIndex++;
        }
        sortList(i);
        return;
      }
    }
  }
}

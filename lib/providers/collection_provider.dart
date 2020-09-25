import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_list.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/models/fuzzy_date.dart';
import 'package:otraku/models/media_entry.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/media_group_provider.dart';

class CollectionProvider with ChangeNotifier implements MediaGroupProvider {
  static const String _url = 'https://graphql.anilist.co';
  static Map<String, String> _headers;
  static int _userId;
  static String _scoreFormat;
  bool _hasSplitCompletedList;
  MediaListSort _mediaListSort;

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
    @required bool hasSplitCompletedList,
    @required MediaListSort mediaListSort,
  }) {
    _headers = headers;
    _userId = userId;
    _scoreFormat = scoreFormat;
    _hasSplitCompletedList = hasSplitCompletedList;
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

  String get scoreFormat {
    return _scoreFormat;
  }

  bool get isEmpty {
    // return !_isLoading && (_lists == null || _lists.length == 0);
    return _lists == null || _lists.length == 0;
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
    if (_lists == null || _lists.length - 1 < _listIndex) return null;

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

    List<dynamic> organisedCollection = [];

    for (final section in sectionOrder) {
      for (int i = 0; i < mediaListCollection.length; i++) {
        if (section == mediaListCollection[i]['name']) {
          organisedCollection.add(mediaListCollection.removeAt(i));
          break;
        }
      }
    }

    if (mediaListCollection.length > 0) {
      for (final list in mediaListCollection) {
        organisedCollection.add(list);
      }
    }

    for (final list in organisedCollection) {
      _lists.add(EntryList(
        name: list['name'],
        status: list['status'],
        isCustomList: list['isCustomList'],
        splitCompletedListFormat: list['isSplitCompletedList']
            ? list['entries'][0]['media']['format']
            : null,
        entries: (list['entries'] as List<dynamic>)
            .map((e) => MediaEntry(
                  mediaId: e['mediaId'],
                  title: e['media']['title']['userPreferred'],
                  cover: e['media']['coverImage']['medium'],
                  format: e['media']['format'],
                  progressMaxString: (e['media'][mediaParts] ?? '?').toString(),
                  entryUserData: EntryUserData(
                    mediaId: e['mediaId'],
                    type: typeUCase,
                    format: e['media']['format'],
                    progress: e['progress'],
                    progressMax: e['media'][mediaParts],
                    score: e['score'].toDouble(),
                    startDate: mapToDateTime(e['startedAt']),
                    endDate: mapToDateTime(e['completedAt']),
                  ),
                ))
            .toList(),
      ));
    }

    _isLoading = false;
    sortCollection();
  }

  //Sorts all lists.
  void sortCollection() {
    for (int i = 0; i < _lists.length; i++) {
      _sortList(_lists[i]);
    }
    notifyListeners();
  }

  //Sorts a list at a given index.
  void _sortList(EntryList list) {
    switch (_mediaListSort) {
      case MediaListSort.TITLE:
        list.entries.sort((a, b) => a.title.compareTo(b.title));
        break;
      case MediaListSort.TITLE_DESC:
        list.entries.sort((a, b) => b.title.compareTo(a.title));
        break;
      case MediaListSort.SCORE:
        list.entries.sort((a, b) {
          int comparison = a.userData.score.compareTo(b.userData.score);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        });
        break;
      case MediaListSort.SCORE_DESC:
        list.entries.sort((a, b) {
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
    _isLoading = true;
    final alreadyAdded = oldData.entryId != null;

    final query = '''
      mutation Update(
        ${alreadyAdded ? '\$id: Int' : ''}
        \$mediaId: Int
        \$status: MediaListStatus
        \$progress: Int
        ${newData.type == 'MANGA' ? '\$progressVolumes: Int' : ''}
        \$repeat: Int
        \$score: Float
        \$notes: String
        \$startedAt: FuzzyDateInput
        \$completedAt: FuzzyDateInput
        \$scoreFormat: ScoreFormat
      ) {
      SaveMediaListEntry(
        ${alreadyAdded ? 'id: \$id' : ''}
        mediaId: \$mediaId, 
        status: \$status,
        progress: \$progress,
        ${newData.type == 'MANGA' ? 'progressVolumes: \$progressVolumes,' : ''}
        repeat: \$repeat,
        score: \$score,
        notes: \$notes,
        startedAt: \$startedAt,
        completedAt: \$completedAt) {
          mediaId
          progress
          score(format: \$scoreFormat)
          startedAt {
            year
            month
            day
          }
          completedAt {
            year
            month
            day
          }
          customLists
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
        'progress': newData.progress,
        'progressVolumes': newData.progressVolumes,
        'repeat': newData.repeat,
        'score': newData.score,
        'notes': newData.notes,
        'startedAt': dateTimeToMap(newData.startDate),
        'completedAt': dateTimeToMap(newData.endDate),
        'scoreFormat': _scoreFormat,
      },
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = (json.decode(result.body) as Map<String, dynamic>)['data']
        ['SaveMediaListEntry'];

    if (data == null) return false;

    //If the entry already existed, remove it from its main list
    //and the custom lists, where it was added.
    String selectedListName;
    if (alreadyAdded) {
      selectedListName = _lists[_listIndex].name;
      _removeLists(oldData);
    }

    //Lists that exist locally and should be updated
    List<EntryList> updatableLists = [];

    //Check if the non-custom list is available
    for (final list in _lists) {
      if (_hasSplitCompletedList &&
          newData.status == MediaListStatus.COMPLETED) {
        if (list.splitCompletedListFormat == newData.format) {
          updatableLists.add(list);
          break;
        }
      } else {
        if (!list.isCustomList && list.status == describeEnum(newData.status)) {
          updatableLists.add(list);
          break;
        }
      }
    }

    //If not available, fetch it.
    if (updatableLists.length == 0) {
      await fetchSingleList(
          status: describeEnum(newData.status),
          splitListFormat: _hasSplitCompletedList &&
                  newData.status == MediaListStatus.COMPLETED
              ? newData.format
              : null);
    }

    //Similarly, all the custom lists that contain the entry, should
    //be added for update or fetched.
    for (final key in newData.customLists.keys
        .where((k) => newData.customLists[k] == true)) {
      final list = _lists.firstWhere(
        (l) => l.isCustomList && l.name == key,
        orElse: () => null,
      );

      if (list == null) {
        await fetchSingleList(
          isCustomList: true,
          name: key,
        );
      } else {
        updatableLists.add(list);
      }
    }

    //Update all the updatable lists
    if (updatableLists.length > 0) {
      final Map<String, bool> customLists = {};
      for (final key in (data['customLists'] as Map<String, dynamic>).keys) {
        customLists[key] = data['customLists'][key];
      }

      final entry = MediaEntry(
        mediaId: data['mediaId'],
        title: data['media']['title']['userPreferred'],
        cover: data['media']['coverImage']['medium'],
        format: data['media']['format'],
        progressMaxString: (data['media'][mediaParts] ?? '?').toString(),
        entryUserData: EntryUserData(
          mediaId: data['mediaId'],
          type: typeUCase,
          format: data['media']['format'],
          progress: data['progress'],
          progressMax: data['media'][mediaParts],
          score: data['score'].toDouble(),
          startDate: mapToDateTime(data['startedAt']),
          endDate: mapToDateTime(data['completedAt']),
          customLists: customLists,
        ),
      );

      for (final list in updatableLists) {
        list.entries.add(entry);
        _sortList(list);
      }
    }

    if (selectedListName != null) {
      for (int i = 0; i < _lists.length; i++) {
        if (_lists[i].name == selectedListName) {
          _listIndex = i;
          break;
        }
      }
    }

    _isLoading = false;
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
    final body = json.decode(response.body)['data']['DeleteMediaListEntry'];

    //Check if the operation was successful
    if (body['deleted'] == null || body['deleted'] == false) return false;

    _removeLists(data);

    notifyListeners();
    return true;
  }

  //Remove an entry from all lists, where its data occured
  void _removeLists(EntryUserData data) {
    List<EntryList> entryHolders = [];

    for (final list in _lists) {
      if (list.isCustomList && data.customLists[list.name] == true) {
        entryHolders.add(list);
        continue;
      }

      if (_hasSplitCompletedList && data.status == MediaListStatus.COMPLETED) {
        if (list.splitCompletedListFormat == data.format) {
          entryHolders.add(list);
          continue;
        }
      } else {
        if (!list.isCustomList && list.status == describeEnum(data.status)) {
          entryHolders.add(list);
          continue;
        }
      }
    }

    for (EntryList list in entryHolders) {
      for (int i = 0; i < list.entries.length; i++) {
        if (list.entries[i].mediaId == data.mediaId) {
          list.entries.removeAt(i);

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
              startedAt {
                year
                month
                day
              }
              completedAt {
                year
                month
                day
              }
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

  //Fetches a single list. If @customListName is null, it gets the non-custom
  //list that corresponds to this status. Otherwise, it gets a custom list
  //with the same name.
  Future<void> fetchSingleList({
    String status,
    String name,
    bool isCustomList = false,
    String splitListFormat,
  }) async {
    final tuple = await fetchLists(status: status);
    final sectionOrder = tuple.item2;
    final listData = tuple.item1.firstWhere(
      (l) =>
          l['isCustomList'] == isCustomList &&
          (splitListFormat == null ||
              l['entries'][0]['media']['format'] == splitListFormat) &&
          (name == null || l['name'] == name),
      orElse: () => null,
    );

    if (listData == null) return;

    final list = EntryList(
      name: listData['name'],
      status: listData['status'],
      isCustomList: listData['isCustomList'],
      splitCompletedListFormat: listData['isSplitCompletedList']
          ? listData['entries'][0]['media']['format']
          : null,
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
                  format: e['media']['format'],
                  progress: e['progress'],
                  progressMax: e['media'][mediaParts],
                  score: e['score'].toDouble(),
                  startDate: mapToDateTime(e['startedAt']),
                  endDate: mapToDateTime(e['completedAt']),
                ),
              ))
          .toList(),
    );
    _sortList(list);

    for (int i = 0; i < sectionOrder.length; i++) {
      if (sectionOrder[i] == list.name) {
        for (int j = i + 1; j < sectionOrder.length; j++) {
          final nextListIndex =
              _lists.indexWhere((l) => l.name == sectionOrder[j]);

          if (nextListIndex != -1) {
            _lists.insert(nextListIndex, list);
            return;
          }
        }

        _lists.add(list);
      }
    }
  }
}

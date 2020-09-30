import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/enum_helper.dart';
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

    if (_search == null || _search == '') {
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
    if (value != null) value = value.trim().toLowerCase();
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
        isCustomList: list['isCustomList'],
        status: list['isCustomList'] ? null : list['status'],
        splitCompletedListFormat: list['isSplitCompletedList']
            ? list['entries'][0]['media']['format']
            : null,
        entries: (list['entries'] as List<dynamic>).map((e) {
          final status = stringToEnum(
            e['status'],
            MediaListStatus.values,
          );

          return MediaEntry(
            mediaId: e['mediaId'],
            title: e['media']['title']['userPreferred'],
            cover: e['media']['coverImage']['large'],
            format: e['media']['format'],
            progressMaxString: (e['media'][mediaParts] ?? '?').toString(),
            entryUserData: EntryUserData(
              mediaId: e['mediaId'],
              type: typeUCase,
              format: e['media']['format'],
              status: status,
              progress: e['progress'],
              progressMax: e['media'][mediaParts],
              score: e['score'].toDouble(),
              startDate: mapToDateTime(e['startedAt']),
              endDate: mapToDateTime(e['completedAt']),
              repeat: e['repeat'],
              notes: e['notes'],
            ),
          );
        }).toList(),
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
      case MediaListSort.PROGRESS:
        list.entries.sort((a, b) {
          int comparison = a.userData.progress.compareTo(b.userData.progress);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        });
        break;
      case MediaListSort.PROGRESS_DESC:
        list.entries.sort((a, b) {
          int comparison = b.userData.progress.compareTo(a.userData.progress);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        });
        break;
      case MediaListSort.REPEAT:
        list.entries.sort((a, b) {
          int comparison = a.userData.repeat.compareTo(b.userData.repeat);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        });
        break;
      case MediaListSort.REPEAT_DESC:
        list.entries.sort((a, b) {
          int comparison = b.userData.repeat.compareTo(a.userData.repeat);
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
        \$private: Boolean
        \$hiddenFromStatusLists: Boolean
        \$customLists: [String]
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
        completedAt: \$completedAt,
        private: \$private,
        hiddenFromStatusLists: \$hiddenFromStatusLists,
        customLists: \$customLists) {
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
        'notes': newData.notes.trim(),
        'startedAt': dateTimeToMap(newData.startDate),
        'completedAt': dateTimeToMap(newData.endDate),
        'private': newData.private,
        'hiddenFromStatusLists': newData.hiddenFromStatusLists,
        'customLists': newData.customLists
            .where((t) => t.item2)
            .map((t) => t.item1)
            .toList(),
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
      _removeEntryFromLists(oldData);
    }

    //Lists that exist locally and should be updated
    List<EntryList> listsForUpdate = [];

    //Check if the non-custom list is available
    if (_hasSplitCompletedList && newData.status == MediaListStatus.COMPLETED) {
      for (final list in _lists) {
        if (list.splitCompletedListFormat == newData.format) {
          listsForUpdate.add(list);
          break;
        }
      }
    } else {
      for (final list in _lists) {
        if (list.status == describeEnum(newData.status)) {
          listsForUpdate.add(list);
          break;
        }
      }
    }

    //If not available, fetch it.
    if (listsForUpdate.length == 0) {
      await fetchSingleList(
          status: describeEnum(newData.status),
          splitListFormat: _hasSplitCompletedList &&
                  newData.status == MediaListStatus.COMPLETED
              ? newData.format
              : null);
    }

    //Similarly, all the custom lists that contain the entry, should
    //be added for update or fetched.
    for (final tuple in newData.customLists) {
      if (tuple.item2) {
        final list = _lists.firstWhere(
          (l) => l.isCustomList && l.name == tuple.item1,
          orElse: () => null,
        );

        if (list == null) {
          await fetchSingleList(
            isCustomList: true,
            name: tuple.item1,
          );
        } else {
          listsForUpdate.add(list);
        }
      }
    }

    //Update all the updatable lists
    if (listsForUpdate.length > 0) {
      final List<Tuple<String, bool>> customLists = [];
      for (final key in data['customLists'].keys) {
        customLists.add(Tuple(key, data['customLists'][key]));
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

      for (final list in listsForUpdate) {
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

    _removeEntryFromLists(data);

    notifyListeners();
    return true;
  }

  //Remove an entry from all lists, where its data occured
  void _removeEntryFromLists(EntryUserData data) {
    List<EntryList> entryHolders = [];

    for (final list in _lists) {
      // print(list.name);
      if (list.isCustomList) {
        // print('this is a custom one');
        for (final tuple in data.customLists) {
          // print(tuple.item1);
          if (tuple.item1 == list.name && tuple.item2) {
            // print('this is a checked one');
            entryHolders.add(list);
            break;
          }
        }
        continue;
      }

      if (!data.hiddenFromStatusLists) {
        if (_hasSplitCompletedList &&
            data.status == MediaListStatus.COMPLETED) {
          if (list.splitCompletedListFormat == data.format) {
            entryHolders.add(list);
          }
        } else {
          if (list.status == describeEnum(data.status)) {
            entryHolders.add(list);
          }
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
              repeat
              notes
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
                  large
                }
              }
            }
          }
        }
        User(id: \$userId) {
          mediaListOptions {
            ${typeLCase}List {
              sectionOrder
              customLists
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

    final lists = result['MediaListCollection']['lists'];
    final List<dynamic> customListNames =
        result['User']['mediaListOptions']['${typeLCase}List']['customLists'];

    for (String name in customListNames) {
      for (final list in lists) {
        if (list['isCustomList'] &&
            list['name'].toString().toLowerCase() == name.toLowerCase()) {
          list['name'] = name;
        }
      }
    }

    return Tuple(
      lists,
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
      isCustomList: listData['isCustomList'],
      status: listData['isCustomList'] ? null : listData['status'],
      splitCompletedListFormat: listData['isSplitCompletedList']
          ? listData['entries'][0]['media']['format']
          : null,
      entries: (listData['entries'] as List<dynamic>).map((e) {
        final status = stringToEnum(
          e['status'],
          MediaListStatus.values,
        );

        return MediaEntry(
          mediaId: e['mediaId'],
          title: e['media']['title']['userPreferred'],
          cover: e['media']['coverImage']['large'],
          format: e['media']['format'],
          progressMaxString: (e['media'][mediaParts] ?? '?').toString(),
          entryUserData: EntryUserData(
            mediaId: e['mediaId'],
            type: typeUCase,
            format: e['media']['format'],
            status: status,
            progress: e['progress'],
            progressMax: e['media'][mediaParts],
            score: e['score'].toDouble(),
            startDate: mapToDateTime(e['startedAt']),
            endDate: mapToDateTime(e['completedAt']),
            notes: e['notes'],
            repeat: e['repeat'],
          ),
        );
      }).toList(),
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
        return;
      }
    }
  }
}

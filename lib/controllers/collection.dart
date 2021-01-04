import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/models/anilist/entry_list.dart';
import 'package:otraku/models/anilist/media_entry_data.dart';
import 'package:otraku/models/anilist/media_list_data.dart';
import 'package:otraku/services/filterable.dart';
import 'package:otraku/services/graph_ql.dart';

class Collection extends GetxController implements Filterable {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const ANIME = 'anime';
  static const MANGA = 'manga';

  static const _collectionQuery = r'''
    query Collection($userId: Int, $type: MediaType) {
      MediaListCollection(userId: $userId, type: $type) {
        lists {
          name
          isCustomList
          isSplitCompletedList
          status
          entries {
            mediaId
            status
            score
            progress
            progressVolumes
            repeat
            notes
            startedAt {year month day}
            completedAt {year month day}
            updatedAt
            createdAt
            media {
              title {userPreferred}
              format
              status(version: 2)
              startDate {year month day}
              endDate {year month day}
              episodes
              chapters
              volumes
              coverImage {large}
              nextAiringEpisode {timeUntilAiring episode}
              genres
            }
          }
        }
        user {
          mediaListOptions {
            rowOrder
            scoreFormat
            animeList {sectionOrder customLists splitCompletedSectionByFormat}
            mangaList {sectionOrder customLists splitCompletedSectionByFormat}
          }
        }
      }
    }
  ''';

  static const _updateEntryMutation = r'''
    mutation UpdateEntry($mediaId: Int, $status: ListStatus,
        $score: Float, $progress: Int, $progressVolumes: Int, $repeat: Int,
        $private: Boolean, $notes: String, $hiddenFromStatusLists: Boolean,
        $customLists: [String], $startedAt: FuzzyDateInput, $completedAt: FuzzyDateInput) {
      SaveMediaListEntry(mediaId: $mediaId, status: $status,
        score: $score, progress: $progress, progressVolumes: $progressVolumes,
        repeat: $repeat, private: $private, notes: $notes,
        hiddenFromStatusLists: $hiddenFromStatusLists, customLists: $customLists,
        startedAt: $startedAt, completedAt: $completedAt) {
          mediaId
          status
          score
          progress
          progressVolumes
          repeat
          notes
          startedAt {year month day}
          completedAt {year month day}
          updatedAt
          createdAt
          media {
            title {userPreferred}
            format
            status(version: 2)
            startDate {year month day}
            endDate {year month day}
            episodes
            chapters
            volumes
            coverImage {large}
            nextAiringEpisode {timeUntilAiring episode}
            genres
          }
        }
    }
  ''';

  static const _removeEntryMutation = r'''
    mutation RemoveEntry($entryId: Int) {DeleteMediaListEntry(id: $entryId) {deleted}}
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int userId;
  final bool ofAnime;
  final _lists = List<EntryList>();
  final _entries = List<MediaListData>().obs;
  final _listIndex = 0.obs;
  final Map<String, dynamic> _filters = {};
  final _fetching = false.obs;
  final List<String> _customListNames = [];
  String _scoreFormat;

  Collection(this.userId, this.ofAnime);

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  bool get fetching => _fetching();

  int get listIndex => _listIndex();

  String get scoreFormat => _scoreFormat;

  List<String> get customListNames => [..._customListNames];

  set listIndex(int value) {
    if (value < 0 || value >= _lists.length || value == _listIndex()) return;
    _listIndex.value = value;
    filter();
  }

  void sort() {
    for (final list in _lists) list.sort(_filters[Filterable.SORT]);
    filter();
  }

  List<MediaListData> get entries => _entries();

  String get currentName => _lists[_listIndex()].name;

  int get currentCount => _lists[_listIndex()].entries.length;

  int get totalEntryCount {
    int c = 0;
    for (final list in _lists)
      if (list.status != null) c += list.entries.length;
    return c;
  }

  List<String> get names {
    List<String> n = [];
    for (final list in _lists) n.add(list.name);
    return n;
  }

  List<int> get allEntryCounts {
    List<int> c = [];
    for (final list in _lists) c.add(list.entries.length);
    return c;
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    _fetching.value = true;
    Map<String, dynamic> data = await GraphQl.request(
      _collectionQuery,
      {
        'userId': userId ?? GraphQl.viewerId,
        'type': ofAnime ? 'ANIME' : 'MANGA',
      },
      popOnError: userId != null,
    );

    if (data == null) {
      _fetching.value = false;
      return null;
    }

    data = data['MediaListCollection'];

    final metaData = ofAnime
        ? data['user']['mediaListOptions']['animeList']
        : data['user']['mediaListOptions']['mangaList'];
    final bool splitCompleted = metaData['splitCompletedSectionByFormat'];

    _scoreFormat = data['user']['mediaListOptions']['scoreFormat'];
    _filters[Filterable.SORT] = ListSortHelper.getEnum(
      data['user']['mediaListOptions']['rowOrder'],
    );

    _customListNames.clear();
    _customListNames.addAll(List.from(metaData['customLists']));

    _lists.clear();
    for (final String section in metaData['sectionOrder']) {
      final index = (data['lists'] as List<dynamic>)
          .indexWhere((listData) => listData['name'] == section);

      if (index == -1) continue;

      final l = (data['lists'] as List<dynamic>).removeAt(index);

      _lists.add(EntryList(l, splitCompleted)..sort(_filters[Filterable.SORT]));
    }

    for (final l in data['lists'])
      _lists.add(EntryList(l, splitCompleted)..sort(_filters[Filterable.SORT]));

    _listIndex.value = 0;
    filter();
    _fetching.value = false;
  }

  Future<void> updateEntry(
      MediaEntryData oldEntry, MediaEntryData newEntry) async {
    // Update database item
    final List<String> oldCustomLists =
        oldEntry.customLists.where((t) => t.item2).map((t) => t.item1).toList();
    final List<String> newCustomLists =
        newEntry.customLists.where((t) => t.item2).map((t) => t.item1).toList();
    newEntry.status ??= ListStatus.CURRENT;

    final data = await GraphQl.request(
      _updateEntryMutation,
      {
        'mediaId': newEntry.mediaId,
        'status': describeEnum(newEntry.status),
        'progress': newEntry.progress,
        'progressVolumes': newEntry.progressVolumes,
        'score': newEntry.score,
        'repeat': newEntry.repeat,
        'notes': newEntry.notes,
        'startedAt': dateTimeToMap(newEntry.startedAt),
        'completedAt': dateTimeToMap(newEntry.completedAt),
        'private': newEntry.private,
        'hiddenFromStatusLists': newEntry.hiddenFromStatusLists,
        'customLists': newCustomLists,
      },
    );

    if (data == null) return;

    final entry = MediaListData(data['SaveMediaListEntry']);

    // Update the status lists. If the list in which the
    // entry was moved to isn't present locally, refetch.
    if (oldEntry.status != newEntry.status) {
      bool foundNewList = false;

      for (final list in _lists)
        if (!list.isCustomList) {
          if (list.status == oldEntry.status) {
            for (int i = 0; i < list.entries.length; i++)
              if (list.entries[i].mediaId == entry.mediaId) {
                list.entries.removeAt(i);
                break;
              }
          } else if (list.status == newEntry.status) {
            list.entries.add(entry);
            list.sort(_filters[Filterable.SORT]);
            foundNewList = true;
          }
        }

      if (!foundNewList) {
        fetch();
        return;
      }
    }

    // Update the custom lists. If a list, in which the
    // entry was added isn't present locally, refetch.
    for (int i = 0; i < oldCustomLists.length; i++)
      oldCustomLists[i] = oldCustomLists[i].toLowerCase();
    for (int i = 0; i < newCustomLists.length; i++)
      newCustomLists[i] = newCustomLists[i].toLowerCase();

    for (final list in _lists) {
      if (list.isCustomList) {
        final name = list.name.toLowerCase();

        bool wasHolder = false;
        for (int i = 0; i < oldCustomLists.length; i++)
          if (oldCustomLists[i] == name) {
            oldCustomLists.removeAt(i);
            wasHolder = true;
            break;
          }

        bool isHolder = false;
        for (int i = 0; i < newCustomLists.length; i++)
          if (newCustomLists[i] == name) {
            newCustomLists.removeAt(i);
            isHolder = true;
            break;
          }

        if (wasHolder != isHolder) {
          if (wasHolder)
            for (int i = 0; i < list.entries.length; i++) {
              if (list.entries[i].mediaId == entry.mediaId) {
                list.entries.removeAt(i);
                break;
              }
            }
          else {
            list.entries.add(entry);
            list.sort(_filters[Filterable.SORT]);
          }
        }
      }
    }

    if (newCustomLists.isNotEmpty) {
      fetch();
      return;
    }

    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex.value) _listIndex.value--;
        _lists.removeAt(i--);
      }

    filter();
  }

  Future<void> removeEntry(MediaEntryData entry) async {
    final data = await GraphQl.request(
      _removeEntryMutation,
      {'entryId': entry.entryId},
      popOnError: false,
    );

    if (data == null || data['DeleteMediaListEntry']['deleted'] == false)
      return;

    final List<String> customLists = [];
    for (final tuple in entry.customLists)
      if (tuple.item2) customLists.add(tuple.item1.toLowerCase());

    for (final list in _lists)
      if (!entry.hiddenFromStatusLists && entry.status == list.status) {
        for (int j = 0; j < list.entries.length; j++)
          if (entry.mediaId == list.entries[j].mediaId) {
            list.entries.removeAt(j);
            break;
          }
      } else if (list.isCustomList &&
          customLists.contains(list.name.toLowerCase())) {
        for (int j = 0; j < list.entries.length; j++)
          if (entry.mediaId == list.entries[j].mediaId) {
            list.entries.removeAt(j);
            break;
          }
      }

    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex.value) _listIndex.value--;
        _lists.removeAt(i--);
      }

    filter();
  }

  // ***************************************************************************
  // FILTERING
  // ***************************************************************************

  void filter() {
    final search = (_filters[Filterable.SEARCH] as String)?.toLowerCase();
    final formatIn = _filters[Filterable.FORMAT_IN];
    final statusIn = _filters[Filterable.STATUS_IN];
    final List<String> genreIn = _filters[Filterable.GENRE_IN];
    final List<String> genreNotIn = _filters[Filterable.GENRE_NOT_IN];

    final list = _lists[_listIndex()];
    final List<MediaListData> e = [];

    for (final entry in list.entries) {
      if (search != null && !entry.title.toLowerCase().contains(search))
        continue;

      if (formatIn != null) {
        bool isIn = false;
        for (final format in formatIn)
          if (entry.format == format) {
            isIn = true;
            break;
          }
        if (!isIn) continue;
      }

      if (statusIn != null) {
        bool isIn = false;
        for (final status in statusIn)
          if (entry.status == status) {
            isIn = true;
            break;
          }
        if (!isIn) continue;
      }

      if (genreIn != null) {
        bool isIn = false;
        for (final genre in entry.genres)
          if (genreIn.contains(genre)) {
            isIn = true;
            break;
          }
        if (!isIn) continue;
      }

      if (genreNotIn != null) {
        bool isIn = false;
        for (final genre in entry.genres)
          if (genreNotIn.contains(genre)) {
            isIn = true;
            break;
          }
        if (isIn) continue;
      }

      e.add(entry);
    }

    _entries.assignAll(e);
  }

  @override
  dynamic getFilterWithKey(String key) => _filters[key];

  @override
  void setFilterWithKey(String key, {dynamic value, bool update = false}) {
    if (value == null ||
        (value is List && value.isEmpty) ||
        (value is String && value.trim().isEmpty)) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }

    if (update) filter();
  }

  @override
  void clearAllFilters({bool update = true}) => clearFiltersWithKeys([
        Filterable.STATUS_IN,
        Filterable.FORMAT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
      ], update: update);

  @override
  void clearFiltersWithKeys(List<String> keys, {bool update = true}) {
    for (final key in keys) {
      _filters.remove(key);
    }

    if (update) filter();
  }

  @override
  bool anyActiveFilterFrom(List<String> keys) {
    for (final key in keys) if (_filters.containsKey(key)) return true;
    return false;
  }
}

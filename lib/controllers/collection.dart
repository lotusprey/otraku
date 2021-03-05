import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/models/anilist/collection_list_model.dart';
import 'package:otraku/models/anilist/entry_model.dart';
import 'package:otraku/models/anilist/list_entry_model.dart';
import 'package:otraku/helpers/filterable.dart';
import 'package:otraku/helpers/client.dart';
import 'package:otraku/helpers/scroll_x_controller.dart';

class Collection extends ScrollxController implements Filterable {
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
    mutation UpdateEntry($mediaId: Int, $status: MediaListStatus,
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
  final _lists = <CollectionListModel>[];
  final _entries = <ListEntryModel>[].obs;
  final _listIndex = 0.obs;
  final Map<String, dynamic> _filters = {};
  final _isLoading = false.obs;
  final List<String> _customListNames = [];
  ScoreFormat _scoreFormat;

  Collection(this.userId, this.ofAnime);

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  bool get isLoading => _isLoading();
  int get listIndex => _listIndex();
  ScoreFormat get scoreFormat => _scoreFormat;
  List<String> get customListNames => [..._customListNames];
  List<ListEntryModel> get entries => _entries();
  String get currentName => _lists[_listIndex()].name;
  ListStatus get listStatus => _lists[_listIndex()].status;
  int get currentCount => _lists[_listIndex()].entries.length;
  bool get isEmpty => _entries.isEmpty;
  bool get isFullyEmpty => _lists.isEmpty;

  set listIndex(int value) {
    if (value < 0 || value >= _lists.length || value == _listIndex()) return;
    _listIndex.value = value;
    filter();
  }

  void sort() {
    for (final list in _lists) list.sort(_filters[Filterable.SORT]);
    filter();
  }

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
    _isLoading.value = true;
    Map<String, dynamic> data = await Client.request(
      _collectionQuery,
      {
        'userId': userId ?? Client.viewerId,
        'type': ofAnime ? 'ANIME' : 'MANGA',
      },
      popOnErr: userId != null,
    );

    if (data == null) {
      _isLoading.value = false;
      return null;
    }

    data = data['MediaListCollection'];

    final metaData = ofAnime
        ? data['user']['mediaListOptions']['animeList']
        : data['user']['mediaListOptions']['mangaList'];
    final bool splitCompleted = metaData['splitCompletedSectionByFormat'];

    _scoreFormat = FnHelper.stringToEnum(
      data['user']['mediaListOptions']['scoreFormat'],
      ScoreFormat.values,
    );
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

      _lists.add(CollectionListModel(l, splitCompleted)
        ..sort(_filters[Filterable.SORT]));
    }

    for (final l in data['lists'])
      _lists.add(CollectionListModel(l, splitCompleted)
        ..sort(_filters[Filterable.SORT]));

    _listIndex.value = 0;
    filter();
    _isLoading.value = false;
  }

  Future<void> updateEntry(
    EntryModel oldEntry,
    EntryModel newEntry,
  ) async {
    // Update database item
    final List<String> oldCustomLists = oldEntry.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();
    final List<String> newCustomLists = newEntry.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    newEntry.status ??= ListStatus.CURRENT;

    final data = await Client.request(
      _updateEntryMutation,
      {
        'mediaId': newEntry.mediaId,
        'status': describeEnum(newEntry.status),
        'progress': newEntry.progress,
        'progressVolumes': newEntry.progressVolumes,
        'score': newEntry.score,
        'repeat': newEntry.repeat,
        'notes': newEntry.notes,
        'startedAt': FnHelper.dateTimeToMap(newEntry.startedAt),
        'completedAt': FnHelper.dateTimeToMap(newEntry.completedAt),
        'private': newEntry.private,
        'hiddenFromStatusLists': newEntry.hiddenFromStatusLists,
        'customLists': newCustomLists,
      },
    );

    if (data == null) return;

    final entry = ListEntryModel(data['SaveMediaListEntry']);

    for (int i = 0; i < newCustomLists.length; i++)
      newCustomLists[i] = newCustomLists[i].toLowerCase();

    // Remove from old status list
    if (!oldEntry.hiddenFromStatusLists)
      for (final list in _lists)
        if (oldEntry.status != null &&
            oldEntry.status == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.removeByMediaId(entry.mediaId);
          break;
        }

    // Remove from old custom lists
    if (oldCustomLists.isNotEmpty)
      for (final list in _lists)
        for (int i = 0; i < oldCustomLists.length; i++)
          if (oldCustomLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(entry.mediaId);
            oldCustomLists.removeAt(i);
            break;
          }

    // Add to new status list
    if (!newEntry.hiddenFromStatusLists) {
      bool added = false;
      for (final list in _lists)
        if (newEntry.status == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.insertSorted(entry, _filters[Filterable.SORT]);
          added = true;
          break;
        }
      if (!added) {
        fetch();
        return;
      }
    }

    // Add to new custom lists
    if (newCustomLists.isNotEmpty) {
      for (final list in _lists)
        for (int i = 0; i < newCustomLists.length; i++)
          if (newCustomLists[i] == list.name.toLowerCase()) {
            list.insertSorted(entry, _filters[Filterable.SORT]);
            newCustomLists.removeAt(i);
            break;
          }
      if (newCustomLists.isNotEmpty) {
        fetch();
        return;
      }
    }

    // Remove empty lists
    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex.value) _listIndex.value--;
        _lists.removeAt(i--);
      }

    filter();
  }

  Future<void> removeEntry(EntryModel entry) async {
    final data = await Client.request(
      _removeEntryMutation,
      {'entryId': entry.entryId},
      popOnErr: false,
    );

    if (data == null || data['DeleteMediaListEntry']['deleted'] == false)
      return;

    final List<String> customLists = [];
    for (final cl in entry.customLists.entries)
      if (cl.value) customLists.add(cl.key.toLowerCase());

    for (final list in _lists)
      if ((!entry.hiddenFromStatusLists &&
              entry.status == list.status &&
              !list.isCustomList) ||
          (list.isCustomList && customLists.contains(list.name.toLowerCase())))
        list.removeByMediaId(entry.mediaId);

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
    if (_lists.isEmpty) return;

    final search = (_filters[Filterable.SEARCH] as String)?.toLowerCase();
    final formatIn = _filters[Filterable.FORMAT_IN];
    final statusIn = _filters[Filterable.STATUS_IN];
    final List<String> genreIn = _filters[Filterable.GENRE_IN];
    final List<String> genreNotIn = _filters[Filterable.GENRE_NOT_IN];

    final list = _lists[_listIndex()];
    final List<ListEntryModel> e = [];

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

    scrollTo(0);
    _entries.assignAll(e);
    // [ERROR:flutter/lib/ui/ui_dart_state.cc(177)] Unhandled Exception: 'package:get/get_rx/src/rx_stream/get_stream.dart': Failed assertion: line 95 pos 12: '!isClosed': You cannot add event to closed Stream
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

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}

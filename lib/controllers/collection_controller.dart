import 'dart:math';

import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/models/list_model.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class CollectionController extends ScrollingController {
  static const ID_HEAD = 0;
  static const ID_BODY = 1;

  static final _random = Random();

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  CollectionController(this.userId, this.ofAnime);

  final int userId;
  final bool ofAnime;
  final _lists = <ListModel>[];
  final _entries = <ListEntryModel>[];
  late final filters = CollectionFilterModel(ofAnime, _onFilterChange);
  int _listIndex = 0;
  bool _isLoading = true;
  String? _search;
  ScoreFormat? _scoreFormat;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  int get listIndex => _listIndex;
  bool get isLoading => _isLoading;
  bool get isEmpty => _lists.isEmpty;
  String? get search => _search;
  int get listCount => _lists.length;
  ScoreFormat? get scoreFormat => _scoreFormat;
  List<ListEntryModel> get entries => _entries;

  set search(String? val) {
    val = val?.trimLeft();
    if (_search == val) return;
    final oldVal = _search;
    _search = val;

    if ((oldVal == null) != (val == null)) {
      update([ID_HEAD]);
      if ((oldVal?.isNotEmpty ?? false) || (val?.isNotEmpty ?? false))
        _filter();
    } else
      _filter();
  }

  List<String> get listNames {
    final n = <String>[];
    for (final list in _lists) n.add(list.name);
    return n;
  }

  List<int> get listCounts {
    final c = <int>[];
    for (final list in _lists) c.add(list.entries.length);
    return c;
  }

  /// Returns a random entry from [_entries].
  ListEntryModel get random => _entries[_random.nextInt(_entries.length)];

  // Getters for the current list.
  String get currentName => _lists[_listIndex].name;
  int get currentCount => _lists[_listIndex].entries.length;

  set listIndex(int val) {
    if (val < 0 || val >= _lists.length || val == _listIndex) return;
    _listIndex = val;
    scrollUpTo(0);
    _filter(true);
  }

  void _onFilterChange(bool withSort) {
    if (withSort) for (final list in _lists) list.sort(filters.sort);
    _filter(true);
  }

  void _filter([bool updateHead = false]) {
    if (_lists.isEmpty) return;

    final searchLower = _search?.toLowerCase() ?? '';
    final tagIdIn = filters.tagIdIn;
    final tagIdNotIn = filters.tagIdNotIn;

    final list = _lists[_listIndex];
    final e = <ListEntryModel>[];

    for (final entry in list.entries) {
      if (searchLower.isNotEmpty) {
        bool contains = false;
        for (final title in entry.titles)
          if (title.toLowerCase().contains(searchLower)) {
            contains = true;
            break;
          }
        if (!contains) continue;
      }

      if (filters.country != null && entry.country != filters.country) continue;

      if (filters.formats.isNotEmpty && !filters.formats.contains(entry.format))
        continue;

      if (filters.statuses.isNotEmpty &&
          !filters.statuses.contains(entry.status)) continue;

      if (filters.genreIn.isNotEmpty) {
        bool isIn = true;
        for (final genre in filters.genreIn)
          if (!entry.genres.contains(genre)) {
            isIn = false;
            break;
          }
        if (!isIn) continue;
      }

      if (filters.genreNotIn.isNotEmpty) {
        bool isIn = false;
        for (final genre in filters.genreNotIn)
          if (entry.genres.contains(genre)) {
            isIn = true;
            break;
          }
        if (isIn) continue;
      }

      if (tagIdIn.isNotEmpty) {
        bool isIn = true;
        for (final tagId in tagIdIn)
          if (!entry.tags.contains(tagId)) {
            isIn = false;
            break;
          }
        if (!isIn) continue;
      }

      if (tagIdNotIn.isNotEmpty) {
        bool isIn = false;
        for (final tagId in tagIdNotIn)
          if (entry.tags.contains(tagId)) {
            isIn = true;
            break;
          }
        if (isIn) continue;
      }

      e.add(entry);
    }

    _entries.clear();
    _entries.addAll(e);
    update([ID_BODY, if (updateHead) ID_HEAD]);
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> _fetch() async {
    Map<String, dynamic>? data = await Client.request(
      GqlQuery.collection,
      {'userId': userId, 'type': ofAnime ? 'ANIME' : 'MANGA'},
    );

    if (data == null) {
      _isLoading = false;
      update([ID_HEAD, ID_BODY]);
      return;
    }

    data = data['MediaListCollection'];

    final metaData = ofAnime
        ? data!['user']['mediaListOptions']['animeList']
        : data!['user']['mediaListOptions']['mangaList'];
    final bool splitCompleted =
        metaData['splitCompletedSectionByFormat'] ?? false;

    _scoreFormat = ScoreFormat.values.byName(
      data['user']?['mediaListOptions']?['scoreFormat'] ?? 'POINT_10_DECIMAL',
    );

    _lists.clear();
    for (final String section in metaData['sectionOrder']) {
      final index = (data['lists'] as List<dynamic>)
          .indexWhere((listData) => listData['name'] == section);

      if (index == -1) continue;

      final l = (data['lists'] as List<dynamic>).removeAt(index);

      _lists.add(ListModel(l, splitCompleted)..sort(filters.sort));
    }

    for (final l in data['lists'])
      _lists.add(ListModel(l, splitCompleted)..sort(filters.sort));

    scrollUpTo(0);
    if (_listIndex >= _lists.length) _listIndex = 0;
    _isLoading = false;
    _filter(true);
  }

  Future<void> refetch() async {
    _isLoading = true;
    update([ID_HEAD, ID_BODY]);
    await _fetch();
  }

  Future<void> updateEntry(EditModel oldEntry, EditModel newEntry) async {
    // Update database item. Due to AL API bug, the tags cannot be obtained
    // from the [SaveMediaListEntry] mutation, so only half of the data is
    // obtained from the first request. The other half comes from a second
    // request.
    final data = await Client.request(
      GqlMutation.updateEntry,
      newEntry.toMap(),
    );
    if (data == null) return;

    final mediaData = await Client.request(
      GqlQuery.media,
      {'id': newEntry.mediaId, 'withMain': true},
    );
    if (mediaData == null) return;
    data['SaveMediaListEntry']['media'] = mediaData['Media'];

    final entry = ListEntryModel(data['SaveMediaListEntry']);

    // Update the entry model (necessary for the updateEntry() caller).
    newEntry.entryId = data['SaveMediaListEntry']['id'];

    // Find from which custom lists to remove the item and in which to add it.
    final oldCustomLists = oldEntry.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();
    final newCustomLists = newEntry.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from old status list.
    if (oldEntry.status != null && !oldEntry.hiddenFromStatusLists)
      for (final list in _lists)
        if (oldEntry.status == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.removeByMediaId(entry.mediaId);
          break;
        }

    // Remove from old custom lists.
    if (oldCustomLists.isNotEmpty)
      for (final list in _lists)
        for (int i = 0; i < oldCustomLists.length; i++)
          if (oldCustomLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(entry.mediaId);
            oldCustomLists.removeAt(i);
            break;
          }

    // Add to new status list.
    if (!newEntry.hiddenFromStatusLists) {
      bool added = false;
      for (final list in _lists)
        if (entry.listStatus == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.insertSorted(entry, filters.sort);
          added = true;
          break;
        }
      if (!added) {
        _fetch();
        return;
      }
    }

    // Add to new custom lists.
    if (newCustomLists.isNotEmpty) {
      for (final list in _lists)
        for (int i = 0; i < newCustomLists.length; i++)
          if (newCustomLists[i] == list.name.toLowerCase()) {
            list.insertSorted(entry, filters.sort);
            newCustomLists.removeAt(i);
            break;
          }
      if (newCustomLists.isNotEmpty) {
        _fetch();
        return;
      }
    }

    // Remove empty lists.
    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex && _listIndex != 0) {
          _listIndex--;
          scrollUpTo(0);
        }
        _lists.removeAt(i--);
      }

    _filter();
  }

  /// When the progress of an entry is changed, this should be called
  /// to reflect it into the database. When reaching the last episode,
  /// [updateEntry] should be called instead.
  Future<void> updateProgress(ListEntryModel model) async {
    if (model.progressMax != null && model.progress > model.progressMax! - 1)
      return;

    final progress = model.progress;

    // Update database item.
    final data = await Client.request(
      GqlMutation.updateProgress,
      {'mediaId': model.mediaId, 'progress': progress},
    );
    if (data == null) return;

    final sorting = filters.sort;
    final needsSort = sorting == EntrySort.PROGRESS ||
        sorting == EntrySort.PROGRESS_DESC ||
        sorting == EntrySort.UPDATED_AT ||
        sorting == EntrySort.UPDATED_AT_DESC;

    // Update status list.
    for (final list in _lists) {
      if (list.isCustomList ||
          list.status != model.listStatus ||
          (list.splitCompletedListFormat != null &&
              list.splitCompletedListFormat != model.format)) continue;

      for (final entry in list.entries)
        if (entry.mediaId == model.mediaId) {
          entry.progress = progress;
          break;
        }

      if (needsSort) list.sort(sorting);
      break;
    }

    // Update custom lists.
    final customLists = <String>[];
    if (data['SaveMediaListEntry']?['customLists'] != null)
      for (final e in data['SaveMediaListEntry']['customLists'].entries)
        if (e.value) customLists.add(e.key.toString().toLowerCase());

    if (customLists.isNotEmpty)
      for (final list in _lists)
        for (int i = 0; i < customLists.length; i++)
          if (list.isCustomList && customLists[i] == list.name.toLowerCase()) {
            for (final entry in list.entries)
              if (entry.mediaId == model.mediaId) {
                entry.progress = progress;
                break;
              }

            if (needsSort) list.sort(sorting);
            customLists.removeAt(i);
            break;
          }
  }

  Future<void> removeEntry(EditModel entry) async {
    // Update database item.
    final data = await Client.request(
      GqlMutation.removeEntry,
      {'entryId': entry.entryId},
    );

    if (data == null || data['DeleteMediaListEntry']['deleted'] == false)
      return;

    final customLists = entry.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from status list.
    if (!entry.hiddenFromStatusLists)
      for (final list in _lists)
        if (!list.isCustomList && list.status == entry.status)
          list.removeByMediaId(entry.mediaId);

    // Remove from custom lists.
    if (customLists.isNotEmpty)
      for (final list in _lists)
        for (int i = 0; i < customLists.length; i++)
          if (customLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(entry.mediaId);
            customLists.removeAt(i);
            break;
          }

    // Remove empty lists.
    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex && _listIndex != 0) {
          _listIndex--;
          scrollUpTo(0);
        }
        _lists.removeAt(i--);
      }

    _filter();
  }

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }
}

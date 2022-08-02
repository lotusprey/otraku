import 'dart:math';

import 'package:get/get.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/collection/entry.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/edit/edit_model.dart';
import 'package:otraku/filter/filter_models.dart';
import 'package:otraku/collection/entry_list.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';

class CollectionController extends GetxController {
  static const ID_HEAD = 0;
  static const ID_BODY = 1;
  static const ID_SCROLLVIEW = 2;

  static final _random = Random();

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  CollectionController(this.userId, this.ofAnime);

  final int userId;
  final bool ofAnime;
  final _lists = <EntryList>[];
  final _entries = <Entry>[];
  late var _filter = CollectionFilter(ofAnime);
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
  List<Entry> get entries => _entries;
  CollectionFilter get filter => _filter;

  List<Entry> listWithStatus(EntryStatus status) {
    for (final l in _lists) if (l.status == status) return [...l.entries];
    return const [];
  }

  set filter(CollectionFilter val) {
    if (_filter.sort != val.sort)
      for (final list in _lists) list.sort(val.sort);
    _filter = val;
    _filterEntries(true);
  }

  set search(String? val) {
    val = val?.trimLeft();
    if (_search == val) return;
    final oldVal = _search;
    _search = val;

    if ((oldVal == null) != (val == null)) {
      update([ID_HEAD]);
      if ((oldVal?.isNotEmpty ?? false) || (val?.isNotEmpty ?? false))
        _filterEntries();
    } else
      _filterEntries();
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
  Entry get random => _entries[_random.nextInt(_entries.length)];

  // Getters for the current list.
  String get currentName => _lists[_listIndex].name;
  int get currentCount => _lists[_listIndex].entries.length;

  set listIndex(int val) {
    if (val < 0 || val >= _lists.length || val == _listIndex) return;
    _listIndex = val;
    update([ID_SCROLLVIEW]);
    _filterEntries(true);
  }

  void _filterEntries([bool updateHead = false]) {
    if (_lists.isEmpty) return;

    final searchLower = _search?.toLowerCase() ?? '';
    final tagIdIn = _filter.tagIdIn;
    final tagIdNotIn = _filter.tagIdNotIn;

    final list = _lists[_listIndex];
    final e = <Entry>[];

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

      if (_filter.country != null && entry.country != _filter.country) continue;

      if (_filter.formats.isNotEmpty && !_filter.formats.contains(entry.format))
        continue;

      if (_filter.statuses.isNotEmpty &&
          !_filter.statuses.contains(entry.status)) continue;

      if (_filter.genreIn.isNotEmpty) {
        bool isIn = true;
        for (final genre in _filter.genreIn)
          if (!entry.genres.contains(genre)) {
            isIn = false;
            break;
          }
        if (!isIn) continue;
      }

      if (_filter.genreNotIn.isNotEmpty) {
        bool isIn = false;
        for (final genre in _filter.genreNotIn)
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
    update([
      ID_BODY,
      if (updateHead) ...[ID_HEAD, ID_SCROLLVIEW]
    ]);
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> _fetch() async {
    Map<String, dynamic>? data = await Api.request(
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

      _lists.add(EntryList(l, splitCompleted)..sort(_filter.sort));
    }

    for (final l in data['lists'])
      _lists.add(EntryList(l, splitCompleted)..sort(_filter.sort));

    update([ID_SCROLLVIEW]);
    update();
    if (_listIndex >= _lists.length) _listIndex = 0;
    _isLoading = false;
    _filterEntries(true);
  }

  Future<void> refetch() async {
    _isLoading = true;
    update([ID_HEAD, ID_BODY]);
    await _fetch();
  }

  /// Fetch the new version of the [entry], replace
  /// the old version in the lists and return [entry].
  Future<Entry?> updateEntry(Edit oldEdit, Edit newEdit) async {
    late final Entry entry;
    try {
      final data = await Api.get(
        GqlQuery.entry,
        {'userId': userId, 'mediaId': newEdit.mediaId},
      );
      entry = Entry(data['MediaList']);
    } catch (e) {
      return null;
    }

    // Find from which custom lists to remove the item and in which to add it.
    final oldCustomLists = oldEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();
    final newCustomLists = newEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from old status list.
    if (oldEdit.status != null && !oldEdit.hiddenFromStatusLists)
      for (final list in _lists)
        if (oldEdit.status == list.status &&
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
    if (!newEdit.hiddenFromStatusLists) {
      bool added = false;
      for (final list in _lists)
        if (entry.entryStatus == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.insertSorted(entry, _filter.sort);
          added = true;
          break;
        }
      if (!added) {
        _fetch();
        return entry;
      }
    }

    // Add to new custom lists.
    if (newCustomLists.isNotEmpty) {
      for (final list in _lists)
        for (int i = 0; i < newCustomLists.length; i++)
          if (newCustomLists[i] == list.name.toLowerCase()) {
            list.insertSorted(entry, _filter.sort);
            newCustomLists.removeAt(i);
            break;
          }
      if (newCustomLists.isNotEmpty) {
        _fetch();
        return entry;
      }
    }

    // Remove empty lists.
    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex && _listIndex != 0) _listIndex--;
        _lists.removeAt(i--);
      }

    _filterEntries();
    return entry;
  }

  /// When the progress of an entry is changed, this should be called
  /// to reflect it into the database. When reaching the last episode,
  /// [updateEntry] should be called instead.
  Future<void> updateProgress(
    int mediaId,
    int progress,
    List<String> customLists,
    EntryStatus? listStatus,
    String? format,
  ) async {
    final sorting = _filter.sort;
    final needsSort = sorting == EntrySort.PROGRESS ||
        sorting == EntrySort.PROGRESS_DESC ||
        sorting == EntrySort.UPDATED_AT ||
        sorting == EntrySort.UPDATED_AT_DESC;

    // Update status list.
    for (final list in _lists) {
      if (list.isCustomList ||
          list.status != listStatus ||
          (list.splitCompletedListFormat != null &&
              list.splitCompletedListFormat != format)) continue;

      for (final entry in list.entries)
        if (entry.mediaId == mediaId) {
          entry.progress = progress;
          break;
        }

      if (needsSort) list.sort(sorting);
      break;
    }

    // Update custom lists.
    if (customLists.isNotEmpty)
      for (final list in _lists)
        for (int i = 0; i < customLists.length; i++)
          if (list.isCustomList && customLists[i] == list.name.toLowerCase()) {
            for (final entry in list.entries)
              if (entry.mediaId == mediaId) {
                entry.progress = progress;
                break;
              }

            if (needsSort) list.sort(sorting);
            customLists.removeAt(i);
            break;
          }
  }

  Future<void> removeEntry(Edit edit) async {
    final customLists = edit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from status list.
    if (!edit.hiddenFromStatusLists)
      for (final list in _lists)
        if (!list.isCustomList && list.status == edit.status)
          list.removeByMediaId(edit.mediaId);

    // Remove from custom lists.
    if (customLists.isNotEmpty)
      for (final list in _lists)
        for (int i = 0; i < customLists.length; i++)
          if (customLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(edit.mediaId);
            customLists.removeAt(i);
            break;
          }

    // Remove empty lists.
    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex && _listIndex != 0) _listIndex--;
        _lists.removeAt(i--);
      }

    _filterEntries();
  }

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }
}

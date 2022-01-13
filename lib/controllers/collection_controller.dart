import 'dart:math';

import 'package:otraku/constants/score_format.dart';
import 'package:otraku/models/list_model.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class CollectionController extends ScrollingController implements Filterable {
  // GetBuilder ids.
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
  final _filters = <String, dynamic>{};
  final _customListNames = <String>[];
  int _listIndex = 0;
  bool _isLoading = true;
  bool _searchMode = false;
  ScoreFormat? _scoreFormat;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  int get listIndex => _listIndex;
  bool get isLoading => _isLoading;
  bool get isEmpty => _lists.isEmpty;
  bool get searchMode => _searchMode;
  int get listCount => _lists.length;
  ScoreFormat? get scoreFormat => _scoreFormat;
  List<ListEntryModel> get entries => _entries;
  List<String> get customListNames => [..._customListNames];

  set searchMode(bool v) {
    if (_searchMode == v) return;
    _searchMode = v;
    update([ID_HEAD]);
    if (_filters[Filterable.SEARCH] != null)
      setFilterWithKey(Filterable.SEARCH, update: true);
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
    _filter();
  }

  void sort() {
    for (final list in _lists) list.sort(_filters[Filterable.SORT]);
    _filter();
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

    _filters[Filterable.SORT] =
        ofAnime ? Settings().defaultAnimeSort : Settings().defaultMangaSort;

    _customListNames.clear();
    _customListNames.addAll(List.from(metaData['customLists']));

    _lists.clear();
    for (final String section in metaData['sectionOrder']) {
      final index = (data['lists'] as List<dynamic>)
          .indexWhere((listData) => listData['name'] == section);

      if (index == -1) continue;

      final l = (data['lists'] as List<dynamic>).removeAt(index);

      _lists.add(ListModel(l, splitCompleted)..sort(_filters[Filterable.SORT]));
    }

    for (final l in data['lists'])
      _lists.add(ListModel(l, splitCompleted)..sort(_filters[Filterable.SORT]));

    scrollUpTo(0);
    if (_listIndex >= _lists.length) _listIndex = 0;
    _isLoading = false;
    _filter();
  }

  Future<void> refetch() async {
    _isLoading = true;
    update([ID_HEAD, ID_BODY]);
    await _fetch();
  }

  Future<void> updateEntry(EntryModel oldEntry, EntryModel newEntry) async {
    // Update database item.
    final data =
        await Client.request(GqlMutation.updateEntry, newEntry.toMap());
    if (data == null) return;

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
          list.insertSorted(entry, _filters[Filterable.SORT]);
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
            list.insertSorted(entry, _filters[Filterable.SORT]);
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

  Future<void> incrementProgress(ListEntryModel model) async {
    if (model.progress == model.progressMax) return;

    final oldListStatus = model.listStatus;

    // Update database item.
    final data = await Client.request(
      GqlMutation.updateProgress,
      {'mediaId': model.mediaId, 'progress': model.progress + 1},
    );
    if (data == null) return;

    model = ListEntryModel(data['SaveMediaListEntry']);

    final customLists = <String>[];
    if (data['SaveMediaListEntry']['customLists'] != null)
      for (final e in data['SaveMediaListEntry']['customLists'].entries)
        if (e.value) customLists.add(e.key.toString().toLowerCase());

    // Remove from status list.
    for (final list in _lists) {
      if (list.isCustomList ||
          list.status == null ||
          list.status != oldListStatus ||
          (list.splitCompletedListFormat != null &&
              list.splitCompletedListFormat != model.format)) continue;

      list.removeByMediaId(model.mediaId);
      break;
    }

    // Add to status list.
    for (final list in _lists) {
      if (list.isCustomList ||
          list.status == null ||
          list.status != model.listStatus ||
          (list.splitCompletedListFormat != null &&
              list.splitCompletedListFormat != model.format)) continue;

      list.insertSorted(model, _filters[Filterable.SORT]);
      break;
    }

    // Replace in custom lists.
    if (customLists.isNotEmpty)
      for (final list in _lists)
        for (int i = 0; i < customLists.length; i++)
          if (customLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(model.mediaId);
            list.insertSorted(model, _filters[Filterable.SORT]);
            customLists.removeAt(i);
            break;
          }

    // Remove the old status list if it is empty.
    for (int i = 0; i < _lists.length; i++)
      if (_lists[i].entries.isEmpty) {
        if (i <= _listIndex && _listIndex != 0) {
          _listIndex--;
          scrollUpTo(0);
        }
        _lists.removeAt(i);
        break;
      }

    _filter();
  }

  Future<void> removeEntry(EntryModel entry) async {
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

  // ***************************************************************************
  // FILTERING
  // ***************************************************************************

  void _filter([bool updateHeader = true]) {
    if (_lists.isEmpty) return;

    final String? country = _filters[Filterable.COUNTRY];
    final List<String>? formatIn = _filters[Filterable.FORMAT_IN];
    final List<String>? statusIn = _filters[Filterable.STATUS_IN];
    final List<String>? genreIn = _filters[Filterable.GENRE_IN];
    final List<String>? genreNotIn = _filters[Filterable.GENRE_NOT_IN];
    final search =
        (_filters[Filterable.SEARCH] as String?)?.toLowerCase() ?? '';

    final list = _lists[_listIndex];
    final e = <ListEntryModel>[];

    for (final entry in list.entries) {
      if (search != '' && !entry.title.toLowerCase().contains(search)) continue;

      if (country != null && entry.country != country) continue;

      if (formatIn != null && !formatIn.contains(entry.format)) continue;

      if (statusIn != null && !statusIn.contains(entry.status)) continue;

      if (genreIn != null) {
        bool isIn = true;
        for (final genre in genreIn)
          if (!entry.genres.contains(genre)) {
            isIn = false;
            break;
          }
        if (!isIn) continue;
      }

      if (genreNotIn != null) {
        bool isIn = false;
        for (final genre in genreNotIn)
          if (entry.genres.contains(genre)) {
            isIn = true;
            break;
          }
        if (isIn) continue;
      }

      e.add(entry);
    }

    _entries.clear();
    _entries.addAll(e);
    update([ID_BODY, if (updateHeader) ID_HEAD]);
  }

  @override
  dynamic getFilterWithKey(String key) => _filters[key];

  @override
  void setFilterWithKey(String key, {dynamic value, bool update = false}) {
    if (value == null ||
        (value is List && value.isEmpty) ||
        (value is String && value.trim().isEmpty))
      _filters.remove(key);
    else
      _filters[key] = value;

    if (!update) return;

    scrollUpTo(0);
    _filter(false);
  }

  @override
  void clearAllFilters({bool update = true}) => clearFiltersWithKeys([
        Filterable.COUNTRY,
        Filterable.STATUS_IN,
        Filterable.FORMAT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
      ], update: update);

  @override
  void clearFiltersWithKeys(List<String> keys, {bool update = true}) {
    for (final key in keys) _filters.remove(key);

    if (!update) return;

    scrollUpTo(0);
    _filter(false);
  }

  @override
  bool anyActiveFilterFrom(List<String> keys) {
    for (final k in keys) if (_filters.containsKey(k)) return true;
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }
}

import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/list_model.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class CollectionController extends OverscrollController implements Filterable {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _collectionQuery = r'''
    query Collection($userId: Int, $type: MediaType) {
      MediaListCollection(userId: $userId, type: $type) {
        lists {
          name
          isCustomList
          isSplitCompletedList
          status
          entries {...data}
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
  '''
      '''$_fragment''';

  static const _updateEntryMutation = r'''
    mutation UpdateEntry($mediaId: Int, $status: MediaListStatus,
        $score: Float, $progress: Int, $progressVolumes: Int, $repeat: Int,
        $private: Boolean, $notes: String, $hiddenFromStatusLists: Boolean,
        $customLists: [String], $startedAt: FuzzyDateInput, $completedAt: FuzzyDateInput,
        $advancedScores: [Float]) {
      SaveMediaListEntry(mediaId: $mediaId, status: $status, score: $score,
        progress: $progress, progressVolumes: $progressVolumes, repeat: $repeat,
        private: $private, notes: $notes, hiddenFromStatusLists: $hiddenFromStatusLists,
        customLists: $customLists, startedAt: $startedAt, completedAt: $completedAt,
        advancedScores: $advancedScores) {...data}
    }
  '''
      '''$_fragment''';

  static const _updateProgressMutation = r'''
    mutation UpdateProgress($mediaId: Int, $progress: Int) {
      SaveMediaListEntry(mediaId: $mediaId, progress: $progress) {...data customLists}
    }
  '''
      '''$_fragment''';

  static const _fragment = r'''
    fragment data on MediaList {
      id
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
        coverImage {extraLarge}
        nextAiringEpisode {episode airingAt}
        genres
        countryOfOrigin
      }
    }
  ''';

  static const _removeEntryMutation = r'''
    mutation RemoveEntry($entryId: Int) {DeleteMediaListEntry(id: $entryId) {deleted}}
  ''';

  static const ANIME = 'anime';
  static const MANGA = 'manga';

  // GetBuilder ids.
  static const ID_HEAD = 0;
  static const ID_BODY = 1;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int userId;
  final bool ofAnime;
  final _lists = <ListModel>[];
  final _entries = <ListEntryModel>[];
  final _filters = <String, dynamic>{};
  final _customListNames = <String>[];
  int _listIndex = 0;
  bool _isLoading = true;
  ScoreFormat? _scoreFormat;

  CollectionController(this.userId, this.ofAnime);

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  @override
  bool get hasNextPage => false;
  bool get isLoading => _isLoading;
  int get listIndex => _listIndex;
  ScoreFormat? get scoreFormat => _scoreFormat;
  List<String> get customListNames => [..._customListNames];
  List<ListEntryModel> get entries => _entries;
  String get currentName => _lists[_listIndex].name;
  ListStatus? get listStatus => _lists[_listIndex].status;
  int get currentCount => _lists[_listIndex].entries.length;
  bool get isEmpty => _lists.isEmpty;

  set listIndex(int val) {
    if (val < 0 || val >= _lists.length || val == _listIndex) return;
    _listIndex = val;
    scrollUpTo(0);
    filter();
  }

  void sort() {
    for (final list in _lists) list.sort(_filters[Filterable.SORT]);
    filter();
  }

  List<String> get names {
    final n = <String>[];
    for (final list in _lists) n.add(list.name);
    return n;
  }

  List<int> get allEntryCounts {
    final c = <int>[];
    for (final list in _lists) c.add(list.entries.length);
    return c;
  }

  void _updateLoading(bool val) {
    if (_isLoading == val) return;

    _isLoading = val;
    update([ID_HEAD, ID_BODY]);
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> _fetch() async {
    if (_lists.isEmpty) _updateLoading(true);

    Map<String, dynamic>? data = await Client.request(
      _collectionQuery,
      {'userId': userId, 'type': ofAnime ? 'ANIME' : 'MANGA'},
    );

    if (data == null) {
      _updateLoading(false);
      return null;
    }

    data = data['MediaListCollection'];

    final metaData = ofAnime
        ? data!['user']['mediaListOptions']['animeList']
        : data!['user']['mediaListOptions']['mangaList'];
    final bool splitCompleted =
        metaData['splitCompletedSectionByFormat'] ?? false;

    _scoreFormat = Convert.strToEnum(
          data['user']['mediaListOptions']['scoreFormat'],
          ScoreFormat.values,
        ) ??
        ScoreFormat.POINT_10_DECIMAL;

    final key = ofAnime ? Config.DEFAULT_ANIME_SORT : Config.DEFAULT_MANGA_SORT;
    _filters[Filterable.SORT] = EntrySort.values.elementAt(
      Config.storage.read(key) ?? 0,
    );

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

    _listIndex = 0;
    _isLoading = false;
    filter();
  }

  Future<void> refetch() async {
    _entries.clear();
    _lists.clear();
    return _fetch();
  }

  @override
  Future<void> fetchPage() async {}

  Future<void> updateEntry(EntryModel oldEntry, EntryModel newEntry) async {
    // Update database item.
    final data = await Client.request(_updateEntryMutation, newEntry.toMap());
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
        if (i <= _listIndex && _listIndex != 0) _listIndex--;
        _lists.removeAt(i--);
      }

    filter();
  }

  Future<void> incrementProgress(ListEntryModel model) async {
    if (model.progress == model.progressMax) return;

    final oldListStatus = model.listStatus;

    // Update database item.
    final data = await Client.request(
      _updateProgressMutation,
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
        if (i <= _listIndex && _listIndex != 0) _listIndex--;
        _lists.removeAt(i);
        break;
      }

    filter();
  }

  Future<void> removeEntry(EntryModel entry) async {
    // Update database item.
    final data =
        await Client.request(_removeEntryMutation, {'entryId': entry.entryId});

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
        if (i <= _listIndex && _listIndex != 0) _listIndex--;
        _lists.removeAt(i--);
      }

    filter();
  }

  // ***************************************************************************
  // FILTERING
  // ***************************************************************************

  void filter([bool updateHeader = true]) {
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

    scrollUpTo(0);
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

    if (update) {
      scrollUpTo(0);
      filter(false);
    }
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

    if (update) {
      scrollUpTo(0);
      filter(false);
    }
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

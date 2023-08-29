import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/edit/edit_model.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';

final collectionProvider = ChangeNotifierProvider.autoDispose.family(
  (ref, CollectionTag tag) => CollectionNotifier(tag),
);

final collectionFilterProvider = StateProvider.autoDispose.family(
  (ref, CollectionTag tag) => CollectionFilter(tag.ofAnime),
);

final entriesProvider = Provider.autoDispose.family(
  (ref, CollectionTag tag) {
    final collection = ref.watch(collectionProvider(tag));
    if (!collection.state.hasValue || collection.lists.isEmpty) {
      return const <Entry>[];
    }

    final filter = ref.watch(collectionFilterProvider(tag));
    final mediaFilter = filter.mediaFilter;
    final search = filter.search.toLowerCase();

    collection.sort = mediaFilter.sort;

    final entries = <Entry>[];
    final list = collection.lists[collection.index];

    final releaseStartFrom = mediaFilter.startYearFrom != null
        ? DateTime(mediaFilter.startYearFrom!).millisecondsSinceEpoch
        : 0;
    final releaseStartTo = mediaFilter.startYearTo != null
        ? DateTime(mediaFilter.startYearTo! + 1).millisecondsSinceEpoch
        : DateTime.now().add(const Duration(days: 900)).millisecondsSinceEpoch;

    for (final entry in list.entries) {
      if (search.isNotEmpty) {
        bool contains = false;
        for (final title in entry.titles) {
          if (title.toLowerCase().contains(search)) {
            contains = true;
            break;
          }
        }
        if (!contains) continue;
      }

      if (mediaFilter.country != null &&
          entry.country != mediaFilter.country!.code) {
        continue;
      }

      if (mediaFilter.formats.isNotEmpty &&
          !mediaFilter.formats.contains(entry.format)) {
        continue;
      }

      if (mediaFilter.statuses.isNotEmpty &&
          !mediaFilter.statuses.contains(entry.status)) {
        continue;
      }

      if (entry.releaseStart != null) {
        if (releaseStartFrom > entry.releaseStart!) continue;
        if (releaseStartTo < entry.releaseStart!) continue;
      }

      if (mediaFilter.genreIn.isNotEmpty) {
        bool isIn = true;
        for (final genre in mediaFilter.genreIn) {
          if (!entry.genres.contains(genre)) {
            isIn = false;
            break;
          }
        }
        if (!isIn) continue;
      }

      if (mediaFilter.genreNotIn.isNotEmpty) {
        bool isIn = false;
        for (final genre in mediaFilter.genreNotIn) {
          if (entry.genres.contains(genre)) {
            isIn = true;
            break;
          }
        }
        if (isIn) continue;
      }

      if (mediaFilter.tagIdIn.isNotEmpty) {
        bool isIn = true;
        for (final tagId in mediaFilter.tagIdIn) {
          if (!entry.tags.contains(tagId)) {
            isIn = false;
            break;
          }
        }
        if (!isIn) continue;
      }

      if (mediaFilter.tagIdNotIn.isNotEmpty) {
        bool isIn = false;
        for (final tagId in mediaFilter.tagIdNotIn) {
          if (entry.tags.contains(tagId)) {
            isIn = true;
            break;
          }
        }
        if (isIn) continue;
      }

      entries.add(entry);
    }

    return entries;
  },
);

class CollectionNotifier extends ChangeNotifier {
  CollectionNotifier(this.tag) {
    _fetch();
  }

  final CollectionTag tag;
  var _lists = const AsyncValue<List<EntryList>>.loading();
  ScoreFormat _scoreFormat = ScoreFormat.POINT_10_DECIMAL;
  EntrySort? _sort;
  int _index = 0;

  AsyncValue get state => _lists;
  List<EntryList> get lists => _lists.valueOrNull ?? [];
  ScoreFormat get scoreFormat => _scoreFormat;
  int get index => _index;

  set sort(EntrySort val) {
    if (_sort == val) return;
    _sort = val;
    for (final l in lists) {
      l.sort(val);
    }
  }

  set index(int val) {
    if (_index == val) return;
    _index = val;
    notifyListeners();
  }

  Future<void> _fetch() async {
    _lists = await AsyncValue.guard(() async {
      var data = await Api.get(
        GqlQuery.collection,
        {'userId': tag.userId, 'type': tag.ofAnime ? 'ANIME' : 'MANGA'},
      );

      data = data['MediaListCollection'];
      final metaData = data['user']['mediaListOptions']
          [tag.ofAnime ? 'animeList' : 'mangaList'];

      final bool splitCompleted =
          metaData['splitCompletedSectionByFormat'] ?? false;

      _scoreFormat = ScoreFormat.values.byName(
        data['user']?['mediaListOptions']?['scoreFormat'] ?? 'POINT_10_DECIMAL',
      );

      final maps = data['lists'] as List<dynamic>;
      final lists = <EntryList>[];

      for (final String section in metaData['sectionOrder']) {
        final index = maps.indexWhere((l) => l['name'] == section);
        if (index == -1) continue;

        final l = maps.removeAt(index);

        lists.add(EntryList(l, splitCompleted));
      }

      for (final l in maps) {
        lists.add(EntryList(l, splitCompleted));
      }
      return lists;
    });

    final ls = lists;
    if (ls.isNotEmpty && _index >= ls.length) _index = ls.length - 1;

    notifyListeners();
  }

  Future<Entry?> updateEntry(
    Entry entry,
    Edit oldEdit,
    Edit newEdit,
    EntrySort sort,
  ) async {
    // Remove from old status list.
    if (oldEdit.status != null && !oldEdit.hiddenFromStatusLists) {
      for (final list in lists) {
        if (oldEdit.status == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.removeByMediaId(entry.mediaId);
          break;
        }
      }
    }

    // Add to new status list.
    if (!newEdit.hiddenFromStatusLists) {
      bool added = false;
      for (final list in lists) {
        if (entry.entryStatus == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.insertSorted(entry, sort);
          added = true;
          break;
        }
      }

      if (!added) {
        _fetch();
        return entry;
      }
    }

    // Remove from old custom lists.
    final oldCustomLists = oldEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    if (oldCustomLists.isNotEmpty) {
      for (final list in lists) {
        if (list.status != null) continue;

        for (int i = 0; i < oldCustomLists.length; i++) {
          if (oldCustomLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(entry.mediaId);
            oldCustomLists[i] = oldCustomLists.last;
            oldCustomLists.removeLast();
            break;
          }
        }
      }
    }

    // Add to new custom lists.
    final newCustomLists = newEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    if (newCustomLists.isNotEmpty) {
      for (final list in lists) {
        if (list.status != null) continue;

        for (int i = 0; i < newCustomLists.length; i++) {
          if (newCustomLists[i] == list.name.toLowerCase()) {
            list.insertSorted(entry, sort);
            newCustomLists[i] = newCustomLists.last;
            newCustomLists.removeLast();
            break;
          }
        }
      }

      if (newCustomLists.isNotEmpty) {
        _fetch();
        return entry;
      }
    }

    _removeEmptyLists();
    notifyListeners();
    return entry;
  }

  /// An alternative to [updateEntry], that only updates the progress.
  /// When incrementing to last episode, [updateEntry] should be called instead.
  Future<void> updateProgress({
    required int mediaId,
    required int progress,
    required List<String> customLists,
    required EntryStatus? listStatus,
    required String? format,
    required EntrySort sort,
  }) async {
    // Update status list.
    for (final list in lists) {
      if (list.status == null ||
          list.status != listStatus ||
          (list.splitCompletedListFormat != null &&
              list.splitCompletedListFormat != format)) continue;

      for (final entry in list.entries) {
        if (entry.mediaId == mediaId) {
          entry.progress = progress;
          break;
        }
      }

      break;
    }

    // Update custom lists.
    if (customLists.isNotEmpty) {
      for (final list in lists) {
        if (list.status != null) continue;

        for (int i = 0; i < customLists.length; i++) {
          if (customLists[i] == list.name.toLowerCase()) {
            for (final entry in list.entries) {
              if (entry.mediaId == mediaId) {
                entry.progress = progress;
                break;
              }
            }

            customLists[i] = customLists.last;
            customLists.removeLast();
            break;
          }
        }
      }
    }
  }

  Future<void> removeEntry(Edit edit) async {
    final customLists = edit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from status list.
    if (!edit.hiddenFromStatusLists) {
      for (final list in lists) {
        if (list.status != null && list.status == edit.status) {
          list.removeByMediaId(edit.mediaId);
        }
      }
    }

    // Remove from custom lists.
    if (customLists.isNotEmpty) {
      for (final list in lists) {
        for (int i = 0; i < customLists.length; i++) {
          if (customLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(edit.mediaId);
            customLists[i] = customLists.last;
            customLists.removeLast();
            break;
          }
        }
      }
    }

    _removeEmptyLists();
    notifyListeners();
  }

  void _removeEmptyLists() {
    for (int i = 0; i < lists.length; i++) {
      if (lists[i].entries.isEmpty) {
        if (i <= _index && _index != 0) _index--;
        lists.removeAt(i--);
      }
    }
  }
}

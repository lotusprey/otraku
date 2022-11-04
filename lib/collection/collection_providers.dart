import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/edit/edit_model.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';

final collectionProvider = ChangeNotifierProvider.autoDispose.family(
  (ref, CollectionTag tag) => CollectionNotifier(tag),
);

final entriesProvider = Provider.autoDispose.family(
  (ref, CollectionTag tag) {
    final collection = ref.watch(collectionProvider(tag));
    if (!collection.state.hasValue || collection.lists.isEmpty) {
      return const <Entry>[];
    }

    final filter = ref.watch(collectionFilterProvider(tag));
    final search = (ref.watch(searchProvider(tag)) ?? '').toLowerCase();

    collection.sort = filter.sort;

    final entries = <Entry>[];
    final list = collection.lists[collection.index];

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

      if (filter.country != null && entry.country != filter.country!.code) {
        continue;
      }

      if (filter.formats.isNotEmpty && !filter.formats.contains(entry.format)) {
        continue;
      }

      if (filter.statuses.isNotEmpty &&
          !filter.statuses.contains(entry.status)) {
        continue;
      }

      if (filter.genreIn.isNotEmpty) {
        bool isIn = true;
        for (final genre in filter.genreIn) {
          if (!entry.genres.contains(genre)) {
            isIn = false;
            break;
          }
        }
        if (!isIn) continue;
      }

      if (filter.genreNotIn.isNotEmpty) {
        bool isIn = false;
        for (final genre in filter.genreNotIn) {
          if (entry.genres.contains(genre)) {
            isIn = true;
            break;
          }
        }
        if (isIn) continue;
      }

      if (filter.tagIdIn.isNotEmpty) {
        bool isIn = true;
        for (final tagId in filter.tagIdIn) {
          if (!entry.tags.contains(tagId)) {
            isIn = false;
            break;
          }
        }
        if (!isIn) continue;
      }

      if (filter.tagIdNotIn.isNotEmpty) {
        bool isIn = false;
        for (final tagId in filter.tagIdNotIn) {
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

  /// Update an existing entry, taking into account status and custom lists.
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

    // Find from which custom lists to remove.
    final oldCustomLists = oldEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from old custom lists.
    if (oldCustomLists.isNotEmpty) {
      for (final list in lists) {
        for (int i = 0; i < oldCustomLists.length; i++) {
          if (oldCustomLists[i] == list.name.toLowerCase()) {
            list.removeByMediaId(entry.mediaId);
            oldCustomLists.removeAt(i);
            break;
          }
        }
      }
    }

    // Find in which custom lists to add.
    final newCustomLists = newEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Add to new custom lists.
    if (newCustomLists.isNotEmpty) {
      for (final list in lists) {
        for (int i = 0; i < newCustomLists.length; i++) {
          if (newCustomLists[i] == list.name.toLowerCase()) {
            list.insertSorted(entry, sort);
            newCustomLists.removeAt(i);
            break;
          }
        }
      }
      if (newCustomLists.isNotEmpty) {
        _fetch();
        return entry;
      }
    }

    // Remove empty lists.
    for (int i = 0; i < lists.length; i++) {
      if (lists[i].entries.isEmpty) {
        if (i <= _index && _index != 0) _index--;
        lists.removeAt(i--);
      }
    }

    notifyListeners();
    return entry;
  }

  /// Faster alternative to [updateEntry]. Should be used only when
  /// the progress was incremented. When reaching the last episode,
  /// [updateEntry] should be called instead.
  Future<void> updateProgress({
    required int mediaId,
    required int progress,
    required List<String> customLists,
    required EntryStatus? listStatus,
    required String? format,
    required EntrySort sort,
  }) async {
    final mustSort = sort == EntrySort.PROGRESS ||
        sort == EntrySort.PROGRESS_DESC ||
        sort == EntrySort.UPDATED_AT ||
        sort == EntrySort.UPDATED_AT_DESC;

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

      if (mustSort) list.sort(sort);
      break;
    }

    // Update custom lists.
    if (customLists.isNotEmpty) {
      for (final list in lists) {
        for (int i = 0; i < customLists.length; i++) {
          if (list.status == null &&
              customLists[i] == list.name.toLowerCase()) {
            for (final entry in list.entries) {
              if (entry.mediaId == mediaId) {
                entry.progress = progress;
                break;
              }
            }

            if (mustSort) list.sort(sort);
            customLists.removeAt(i);
            break;
          }
        }
      }
    }
  }

  Future<void> removeEntry(Edit edit) async {
    final lists = this.lists;
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
            customLists.removeAt(i);
            break;
          }
        }
      }
    }

    // Remove empty lists.
    for (int i = 0; i < lists.length; i++) {
      if (lists[i].entries.isEmpty) {
        if (i <= _index && _index != 0) _index--;
        lists.removeAt(i--);
      }
    }

    notifyListeners();
  }
}

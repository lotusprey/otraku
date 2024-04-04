import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/edit/edit_model.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/viewer/api.dart';
import 'package:otraku/common/utils/graphql.dart';

final collectionProvider = AsyncNotifierProvider.autoDispose
    .family<CollectionNotifier, Collection, CollectionTag>(
  CollectionNotifier.new,
);

class CollectionNotifier
    extends AutoDisposeFamilyAsyncNotifier<Collection, CollectionTag> {
  var _sort = EntrySort.TITLE;

  @override
  FutureOr<Collection> build(arg) async {
    final index = switch (state.valueOrNull) {
      FullCollection c => c.index,
      _ => 0,
    };

    final isFull = arg.userId != Options().id ||
        ref.watch(homeProvider.select(
          (s) => arg.ofAnime
              ? s.didExpandAnimeCollection
              : s.didExpandMangaCollection,
        ));

    final data = await Api.get(GqlQuery.collection, {
      'userId': arg.userId,
      'type': arg.ofAnime ? 'ANIME' : 'MANGA',
      if (!isFull) 'status_in': ['CURRENT', 'REPEATING'],
    });

    return isFull
        ? FullCollection(data['MediaListCollection'], arg.ofAnime, index)
        : PreviewCollection(data['MediaListCollection']);
  }

  void ensureSorted(EntrySort sort) {
    if (_sort == sort) return;
    _sort = sort;

    _updateState((collection) {
      collection.sort(sort);
      return null;
    });
  }

  void changeIndex(int newIndex) => _updateState(
        (collection) => switch (collection) {
          FullCollection _ => collection.withIndex(newIndex),
          PreviewCollection _ => collection,
        },
      );

  Future<String?> saveEntry(Edit oldEdit, Edit newEdit) async {
    Entry entry;
    try {
      // There is an api bug in entry updating, which prevents tag
      // data from being returned. This is why 2 requests are needed.
      await Api.get(GqlMutation.updateEntry, newEdit.toMap());

      final data = await Api.get(
        GqlQuery.listEntry,
        {'userId': arg.userId, 'mediaId': newEdit.mediaId},
      );

      entry = Entry(data['MediaList']);
    } catch (e) {
      return e.toString();
    }

    _updateState(
      (collection) => switch (collection) {
        FullCollection _ => _saveEntryInFullCollection(
            collection,
            entry,
            oldEdit,
            newEdit,
          ),
        PreviewCollection _ => _saveEntryInPreviewCollection(
            collection,
            entry,
            oldEdit,
            newEdit,
          ),
      },
    );

    return null;
  }

  /// An alternative to [saveEntry], that only updates the progress.
  /// When incrementing to last episode, [saveEntry] should be called instead.
  Future<String?> saveEntryProgress(Entry entry) async {
    final customLists = <String>[];
    try {
      final data = await Api.get(
        GqlMutation.updateProgress,
        {'mediaId': entry.mediaId, 'progress': entry.progress},
      );

      Map items =
          data['SaveMediaListEntry']?['customLists']?.entries ?? const {};

      for (final item in items.entries) {
        if (item.value) customLists.add(item.key.toString().toLowerCase());
      }
    } catch (e) {
      return e.toString();
    }

    _updateState(
      (collection) => switch (collection) {
        FullCollection _ => _saveEntryProgressInFullCollection(
            collection,
            entry,
            customLists,
          ),
        PreviewCollection _ => _saveEntryProgressInPreviewCollection(
            collection,
            entry,
            customLists,
          ),
      },
    );

    return null;
  }

  Future<String?> removeEntry(Edit edit) async {
    if (edit.entryId == null) return 'Missing entry id';

    try {
      await Api.get(GqlMutation.removeEntry, {'entryId': edit.entryId});
    } catch (e) {
      return e.toString();
    }

    _updateState(
      (collection) => switch (collection) {
        FullCollection _ => _removeEntryFromFullCollection(collection, edit),
        PreviewCollection _ => _removeEntryFromPreviewCollection(
            collection,
            edit,
          ),
      },
    );

    return null;
  }

  FullCollection _saveEntryInFullCollection(
    FullCollection collection,
    Entry entry,
    Edit oldEdit,
    Edit newEdit,
  ) {
    final oldCustomLists = oldEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    final newCustomLists = newEdit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from old status list.
    if (oldEdit.status != null && !oldEdit.hiddenFromStatusLists) {
      for (final list in collection.lists) {
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
      for (final list in collection.lists) {
        if (entry.entryStatus == list.status &&
            (list.splitCompletedListFormat == null ||
                list.splitCompletedListFormat == entry.format)) {
          list.insertSorted(entry, _sort);
          added = true;
          break;
        }
      }

      if (!added) {
        ref.invalidateSelf();
      }
    }

    // Remove from old custom lists.
    if (oldCustomLists.isNotEmpty) {
      for (final list in collection.lists) {
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
    if (newCustomLists.isNotEmpty) {
      for (final list in collection.lists) {
        if (list.status != null) continue;

        for (int i = 0; i < newCustomLists.length; i++) {
          if (newCustomLists[i] == list.name.toLowerCase()) {
            list.insertSorted(entry, _sort);
            newCustomLists[i] = newCustomLists.last;
            newCustomLists.removeLast();
            break;
          }
        }
      }

      if (newCustomLists.isNotEmpty) {
        ref.invalidateSelf();
      }
    }

    return _withRemovedEmptyLists(collection);
  }

  PreviewCollection _saveEntryInPreviewCollection(
    PreviewCollection collection,
    Entry entry,
    Edit oldEdit,
    Edit newEdit,
  ) {
    if (newEdit.status == EntryStatus.CURRENT ||
        newEdit.status == EntryStatus.REPEATING) {
      if (oldEdit.status == EntryStatus.CURRENT ||
          oldEdit.status == EntryStatus.REPEATING) {
        final entries = collection.entries;
        for (int i = 0; i < entries.length; i++) {
          if (entries[i].mediaId == entry.mediaId) {
            entries[i] = entry;
            return collection;
          }
        }

        return collection;
      } else {
        collection.entries.add(entry);
        return collection;
      }
    }

    return _removeEntryFromPreviewCollection(collection, oldEdit);
  }

  FullCollection _saveEntryProgressInFullCollection(
    FullCollection collection,
    Entry entry,
    List<String> customLists,
  ) {
    // Update status list.
    for (final list in collection.lists) {
      if (list.status == null ||
          list.status != entry.entryStatus ||
          (list.splitCompletedListFormat != null &&
              list.splitCompletedListFormat != entry.format)) continue;

      for (final e in list.entries) {
        if (e.mediaId == entry.mediaId) {
          e.progress = entry.progress;
          break;
        }
      }

      break;
    }

    // Update custom lists.
    if (customLists.isNotEmpty) {
      for (final list in collection.lists) {
        if (list.status != null) continue;

        for (int i = 0; i < customLists.length; i++) {
          if (customLists[i] == list.name.toLowerCase()) {
            for (final e in list.entries) {
              if (e.mediaId == entry.mediaId) {
                e.progress = entry.progress;
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

    return collection;
  }

  PreviewCollection _saveEntryProgressInPreviewCollection(
    PreviewCollection collection,
    Entry entry,
    List<String> customLists,
  ) {
    final entries = collection.entries;
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].mediaId == entry.mediaId) {
        entries[i].progress = entry.progress;
        return collection;
      }
    }

    return collection;
  }

  FullCollection _removeEntryFromFullCollection(
    FullCollection collection,
    Edit edit,
  ) {
    final customLists = edit.customLists.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    // Remove from status list.
    if (!edit.hiddenFromStatusLists) {
      for (final list in collection.lists) {
        if (list.status != null && list.status == edit.status) {
          list.removeByMediaId(edit.mediaId);
        }
      }
    }

    // Remove from custom lists.
    if (customLists.isNotEmpty) {
      for (final list in collection.lists) {
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

    return _withRemovedEmptyLists(collection);
  }

  PreviewCollection _removeEntryFromPreviewCollection(
    PreviewCollection collection,
    Edit edit,
  ) {
    final entries = collection.entries;
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].mediaId == edit.mediaId) {
        entries.removeAt(i);
        return collection;
      }
    }

    return collection;
  }

  FullCollection _withRemovedEmptyLists(FullCollection collection) {
    final lists = collection.lists;
    int index = collection.index;

    for (int i = 0; i < lists.length; i++) {
      if (lists[i].entries.isEmpty) {
        if (i <= index && index != 0) index--;
        lists.removeAt(i--);
      }
    }

    return collection.withIndex(index);
  }

  void _updateState(Collection? Function(Collection) mutator) {
    if (!state.hasValue) return;
    final result = mutator(state.value!);
    if (result != null) state = AsyncValue.data(result);
  }
}

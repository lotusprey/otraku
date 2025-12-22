import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final collectionProvider = AsyncNotifierProvider.autoDispose
    .family<CollectionNotifier, Collection, CollectionTag>(CollectionNotifier.new);

class CollectionNotifier extends AsyncNotifier<Collection> {
  CollectionNotifier(this.arg);

  final CollectionTag arg;

  var _sort = EntrySort.title;

  @override
  FutureOr<Collection> build() async {
    final fullCollectionIndex = switch (state.value) {
      FullCollection c => c.index,
      _ => -1,
    };

    final viewerId = ref.watch(viewerIdProvider);

    final isFull =
        arg.userId != viewerId ||
        ref.watch(
          homeProvider.select(
            (s) => arg.ofAnime ? s.didExpandAnimeCollection : s.didExpandMangaCollection,
          ),
        );

    final data = await ref.read(repositoryProvider).request(GqlQuery.collection, {
      'userId': arg.userId,
      'type': arg.ofAnime ? 'ANIME' : 'MANGA',
      if (!isFull) 'status_in': ['CURRENT', 'REPEATING'],
    });

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    final collection = isFull
        ? FullCollection(
            data['MediaListCollection'],
            arg.ofAnime,
            fullCollectionIndex,
            imageQuality,
          )
        : PreviewCollection(data['MediaListCollection'], imageQuality);
    collection.sort(_sort);
    return collection;
  }

  void ensureSorted(EntrySort sort, EntrySort previewSort) {
    _updateState((collection) {
      final selectedSort = switch (collection) {
        FullCollection _ => sort,
        PreviewCollection _ => previewSort,
      };

      if (_sort == selectedSort) return;
      _sort = selectedSort;

      collection.sort(selectedSort);
      return null;
    });
  }

  void changeIndex(int newIndex) => _updateState(
    (collection) => switch (collection) {
      FullCollection _ => collection.withIndex(newIndex),
      PreviewCollection _ => collection,
    },
  );

  void removeEntry(int mediaId) {
    _updateState(
      (collection) => switch (collection) {
        PreviewCollection c => c..list.removeByMediaId(mediaId),
        FullCollection c => _withRemovedEmptyLists(
          c..lists.forEach((list) => list.removeByMediaId(mediaId)),
        ),
      },
    );
  }

  /// There is an api bug in entry updating,
  /// which prevents tag data from being returned.
  /// This is why [saveEntry] additionally fetches the updated entry.
  Future<void> saveEntry(int mediaId, ListStatus? oldStatus) async {
    try {
      var data = await ref.read(repositoryProvider).request(GqlQuery.listEntry, {
        'userId': arg.userId,
        'mediaId': mediaId,
      });
      data = data['MediaList'];

      final entry = Entry(data, ref.read(persistenceProvider).options.imageQuality);

      _updateState(
        (collection) => switch (collection) {
          FullCollection _ => _saveEntryInFullCollection(collection, entry, oldStatus, data),
          PreviewCollection _ => _saveEntryInPreviewCollection(
            collection,
            entry,
            oldStatus,
            entry.listStatus,
          ),
        },
      );
    } catch (_) {}
  }

  /// An alternative to [saveEntry],
  /// that only updates the progress and potentially, the list status.
  /// When incrementing to last episode, [saveEntry] should be called instead.
  Future<String?> saveEntryProgress(Entry oldEntry, bool setAsCurrent) async {
    try {
      await ref.read(repositoryProvider).request(GqlMutation.updateProgress, {
        'mediaId': oldEntry.mediaId,
        'progress': oldEntry.progress,
        if (setAsCurrent) ...{
          'status': ListStatus.current.value,
          if (oldEntry.watchStart == null) 'startedAt': DateTime.now().fuzzyDate,
        },
      });

      await saveEntry(oldEntry.mediaId, oldEntry.listStatus);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  FullCollection _saveEntryInFullCollection(
    FullCollection collection,
    Entry entry,
    ListStatus? oldStatus,
    Map<String, dynamic> data,
  ) {
    final hiddenFromStatusLists = data['hiddenFromStatusLists'] ?? false;
    final customListItems = data['customLists'] ?? const <String, dynamic>{};
    final customLists = customListItems.entries
        .where((e) => e.value == true)
        .map((e) => e.key.toLowerCase())
        .toList();

    for (final list in collection.lists) {
      if (list.status != null) {
        if (list.status == oldStatus) {
          if (list.status == entry.listStatus) {
            if (hiddenFromStatusLists) {
              list.removeByMediaId(entry.mediaId);
              continue;
            }

            if (!list.setByMediaId(entry)) {
              list.insertSorted(entry, _sort);
            }

            continue;
          }

          list.removeByMediaId(entry.mediaId);
          continue;
        }

        if (list.status == entry.listStatus) {
          list.insertSorted(entry, _sort);
        }

        continue;
      }

      if (customLists.contains(list.name.toLowerCase())) {
        if (!list.setByMediaId(entry)) {
          list.insertSorted(entry, _sort);
        }

        continue;
      }

      list.removeByMediaId(entry.mediaId);
    }

    return _withRemovedEmptyLists(collection);
  }

  PreviewCollection _saveEntryInPreviewCollection(
    PreviewCollection collection,
    Entry entry,
    ListStatus? oldStatus,
    ListStatus? newStatus,
  ) {
    if (newStatus == .current || newStatus == .repeating) {
      if (oldStatus == .current || oldStatus == .repeating) {
        collection.list.setByMediaId(entry);
        return collection;
      }

      collection.list.insertSorted(entry, _sort);
      return collection;
    }

    collection.list.removeByMediaId(entry.mediaId);
    return collection;
  }

  FullCollection _withRemovedEmptyLists(FullCollection collection) {
    final lists = collection.lists;
    int index = collection.index;

    for (int i = 0; i < lists.length; i++) {
      if (lists[i].entries.isEmpty) {
        if (i <= index) index--;
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

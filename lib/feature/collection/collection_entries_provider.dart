import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_filter_provider.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/feature/filter/filter_collection_model.dart';

final collectionEntriesProvider =
    Provider.autoDispose.family<List<Entry>, CollectionTag>(
  (ref, CollectionTag tag) {
    final filter = ref.watch(collectionFilterProvider(tag));
    final mediaFilter = filter.mediaFilter;
    final search = filter.search.toLowerCase();

    ref.watch(collectionProvider(tag).notifier).ensureSorted(mediaFilter.sort);

    final entries = ref
            .watch(collectionProvider(tag))
            .unwrapPrevious()
            .valueOrNull
            ?.list
            .entries ??
        const [];

    return _filter(entries, mediaFilter, search);
  },
);

List<Entry> _filter(
  List<Entry> allEntries,
  CollectionMediaFilter mediaFilter,
  String search,
) {
  final entries = <Entry>[];
  final releaseStartFrom = mediaFilter.startYearFrom != null
      ? DateTime(mediaFilter.startYearFrom!)
      : DateTime(1920);
  final releaseStartTo = mediaFilter.startYearTo != null
      ? DateTime(mediaFilter.startYearTo! + 1)
      : DateTime.now().add(const Duration(days: 900));

  for (final entry in allEntries) {
    if (search.isNotEmpty) {
      bool contains = false;
      for (final title in entry.titles) {
        if (title.toLowerCase().contains(search)) {
          contains = true;
          break;
        }
      }

      if (!contains && entry.notes.toLowerCase().contains(search)) {
        contains = true;
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
        !mediaFilter.statuses.contains(entry.releaseStatus)) {
      continue;
    }

    if (entry.releaseStart != null) {
      if (releaseStartFrom.isAfter(entry.releaseStart!)) continue;
      if (releaseStartTo.isBefore(entry.releaseStart!)) continue;
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

    if (mediaFilter.isPrivate != null &&
        entry.isPrivate != mediaFilter.isPrivate) {
      continue;
    }

    if (mediaFilter.hasNotes != null &&
        entry.notes.isNotEmpty != mediaFilter.hasNotes) {
      continue;
    }

    entries.add(entry);
  }

  return entries;
}

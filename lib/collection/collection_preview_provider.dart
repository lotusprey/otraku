import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/options.dart';

final collectionPreviewProvider = ChangeNotifierProvider.autoDispose.family(
  (ref, CollectionTag tag) => CollectionPreviewNotifier(tag),
);

class CollectionPreviewNotifier extends ChangeNotifier {
  CollectionPreviewNotifier(this.tag) {
    _fetch();
  }

  final CollectionTag tag;
  var _entries = const AsyncValue<List<Entry>>.loading();
  var _scoreFormat = ScoreFormat.POINT_10_DECIMAL;

  AsyncValue get state => _entries;
  List<Entry> get entries => _entries.valueOrNull ?? [];
  ScoreFormat get scoreFormat => _scoreFormat;

  Future<void> _fetch() async {
    _entries = await AsyncValue.guard(() async {
      var data = await Api.get(
        GqlQuery.collectionPreview,
        {'userId': tag.userId, 'type': tag.ofAnime ? 'ANIME' : 'MANGA'},
      );
      data = data['MediaListCollection'];

      _scoreFormat = ScoreFormat.values.byName(
        data['user']?['mediaListOptions']?['scoreFormat'] ?? 'POINT_10_DECIMAL',
      );

      final items = <Entry>[];
      for (final l in data['lists']) {
        if (l['isCustomList']) continue;

        for (final e in l['entries']) {
          items.add(Entry(e));
        }
      }

      final sort = tag.ofAnime
          ? Options().airingSortForPreview
              ? EntrySort.AIRING
              : Options().defaultAnimeSort
          : Options().defaultMangaSort;

      items.sort(entryComparator(sort));
      return items;
    });
    notifyListeners();
  }

  void add(Entry entry) {
    if (entry.entryStatus != EntryStatus.CURRENT &&
        entry.entryStatus != EntryStatus.REPEATING) return;

    _entries.valueOrNull?.add(entry);
    notifyListeners();
  }

  void remove(int mediaId) {
    final items = _entries.valueOrNull;
    if (items == null) return;

    for (int i = 0; i < items.length; i++) {
      if (items[i].mediaId == mediaId) {
        items.removeAt(i);
        notifyListeners();
        return;
      }
    }
  }

  void update(Entry entry) {
    if (entry.entryStatus != EntryStatus.CURRENT &&
        entry.entryStatus != EntryStatus.REPEATING) {
      remove(entry.mediaId);
      return;
    }

    final items = _entries.valueOrNull;
    if (items == null) return;

    for (int i = 0; i < items.length; i++) {
      if (items[i].mediaId == entry.mediaId) {
        items[i] = entry;
        notifyListeners();
        return;
      }
    }
  }
}

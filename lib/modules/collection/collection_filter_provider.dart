import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/media/media_models.dart';

final collectionFilterProvider = NotifierProvider.autoDispose
    .family<CollectionFilterNotifier, CollectionFilter, CollectionTag>(
  CollectionFilterNotifier.new,
);

class CollectionFilterNotifier
    extends AutoDisposeFamilyNotifier<CollectionFilter, CollectionTag> {
  @override
  CollectionFilter build(arg) {
    final filter = CollectionFilter(arg.ofAnime);
    final selectIsInAnimePreview = homeProvider.select(
      (s) => !s.didExpandAnimeCollection,
    );

    if (arg.userId == Persistence().id &&
        arg.ofAnime &&
        Persistence().airingSortForPreview &&
        ref.watch(selectIsInAnimePreview)) {
      filter.mediaFilter.sort = EntrySort.airing;
    }
    return filter;
  }

  CollectionFilter update(
    CollectionFilter Function(CollectionFilter) callback,
  ) =>
      state = callback(state);
}

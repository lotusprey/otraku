import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/feature/media/media_models.dart';

final collectionFilterProvider = NotifierProvider.autoDispose
    .family<CollectionFilterNotifier, CollectionFilter, CollectionTag>(
  CollectionFilterNotifier.new,
);

class CollectionFilterNotifier
    extends AutoDisposeFamilyNotifier<CollectionFilter, CollectionTag> {
  @override
  CollectionFilter build(arg) {
    final options = ref.watch(persistenceProvider.select((s) => s.options));
    final filter = CollectionFilter(
      arg.ofAnime ? options.defaultAnimeSort : options.defaultMangaSort,
    );
    final selectIsInAnimePreview = homeProvider.select(
      (s) => !s.didExpandAnimeCollection,
    );

    if (arg.userId == ref.watch(viewerIdProvider) &&
        arg.ofAnime &&
        options.airingSortForAnimePreview &&
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

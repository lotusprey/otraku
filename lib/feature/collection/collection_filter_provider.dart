import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_filter_model.dart';
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
    final mediaFilter = arg.ofAnime
        ? ref.watch(
            persistenceProvider.select((s) => s.animeCollectionMediaFilter),
          )
        : ref.watch(
            persistenceProvider.select((s) => s.mangaCollectionMediaFilter),
          );

    final options = ref.watch(persistenceProvider.select((s) => s.options));
    final isInAnimePreviewProvider = homeProvider.select(
      (s) => !s.didExpandAnimeCollection,
    );

    if (arg.userId == ref.watch(viewerIdProvider) &&
        arg.ofAnime &&
        options.airingSortForAnimePreview &&
        ref.watch(isInAnimePreviewProvider)) {
      mediaFilter.sort = EntrySort.airing;
    }

    return CollectionFilter(mediaFilter);
  }

  CollectionFilter update(
    CollectionFilter Function(CollectionFilter) callback,
  ) =>
      state = callback(state);
}

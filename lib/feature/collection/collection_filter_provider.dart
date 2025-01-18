import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/collection/collection_models.dart';

final collectionFilterProvider = NotifierProvider.autoDispose
    .family<CollectionFilterNotifier, CollectionFilter, CollectionTag>(
  CollectionFilterNotifier.new,
);

class CollectionFilterNotifier
    extends AutoDisposeFamilyNotifier<CollectionFilter, CollectionTag> {
  @override
  CollectionFilter build(arg) {
    final mediaFilter = ref.watch(persistenceProvider.select(
      (s) => arg.ofAnime
          ? s.animeCollectionMediaFilter
          : s.mangaCollectionMediaFilter,
    ));

    return CollectionFilter(mediaFilter.copy());
  }

  CollectionFilter update(
    CollectionFilter Function(CollectionFilter) callback,
  ) =>
      state = callback(state);
}

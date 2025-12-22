import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/collection/collection_models.dart';

final collectionFilterProvider = NotifierProvider.autoDispose
    .family<CollectionFilterNotifier, CollectionFilter, CollectionTag>(
      CollectionFilterNotifier.new,
    );

class CollectionFilterNotifier extends Notifier<CollectionFilter> {
  CollectionFilterNotifier(this.arg);

  final CollectionTag arg;

  @override
  CollectionFilter build() {
    final mediaFilter = ref.watch(
      persistenceProvider.select(
        (s) => arg.ofAnime ? s.animeCollectionMediaFilter : s.mangaCollectionMediaFilter,
      ),
    );

    return CollectionFilter(mediaFilter.copy());
  }

  CollectionFilter update(CollectionFilter Function(CollectionFilter) callback) =>
      state = callback(state);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/filter/filter_models.dart';

final collectionFilterProvider = StateProvider.autoDispose.family(
  (ref, CollectionTag tag) => CollectionFilter(tag.ofAnime),
);

final discoverFilterProvider = StateProvider.autoDispose.family(
  (ref, bool ofAnime) => DiscoverFilter(ofAnime),
);

/// If the [CollectionTag] is `null`, this is related to the discover tab.
/// Otherwise, it's related to a collection.
final searchProvider =
    StateProvider.autoDispose.family<String?, CollectionTag?>((ref, _) => null);

final birthdayFilterProvider = StateProvider.autoDispose((ref) => false);

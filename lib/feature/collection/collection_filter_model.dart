import 'package:otraku/feature/filter/filter_collection_model.dart';
import 'package:otraku/feature/media/media_models.dart';

class CollectionFilter {
  const CollectionFilter._({required this.search, required this.mediaFilter});

  CollectionFilter(EntrySort sort)
      : search = '',
        mediaFilter = CollectionMediaFilter(sort);

  final String search;
  final CollectionMediaFilter mediaFilter;

  CollectionFilter copyWith({
    String? search,
    CollectionMediaFilter? mediaFilter,
  }) =>
      CollectionFilter._(
        search: search ?? this.search,
        mediaFilter: mediaFilter ?? this.mediaFilter,
      );
}

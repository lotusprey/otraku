import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/filter/filter_models.dart';
import 'package:otraku/utils/options.dart';

final collectionFilterProvider = StateProvider.autoDispose.family(
  (ref, CollectionTag tag) => CollectionFilter(tag.ofAnime),
);

/// If the [CollectionTag] is `null`, this is related to the discover tab.
/// Otherwise, it's related to a collection.
final searchProvider =
    StateProvider.autoDispose.family<String?, CollectionTag?>((ref, _) => null);

final discoverFilterProvider = ChangeNotifierProvider.autoDispose(
  (ref) => DiscoverFilterNotifier(Options().defaultDiscoverType),
);

class DiscoverFilterNotifier extends ChangeNotifier {
  DiscoverFilterNotifier(this._type);

  DiscoverType _type;
  late var _filter = DiscoverFilter(_type == DiscoverType.anime);
  bool _birthday = false;

  DiscoverType get type => _type;
  DiscoverFilter get filter => _filter;
  bool get birthday => _birthday;

  set type(DiscoverType val) {
    if (_type == val) return;
    if (val == DiscoverType.anime) {
      _filter = DiscoverFilter(true);
    } else {
      _filter = DiscoverFilter(false);
    }
    _type = val;
    notifyListeners();
  }

  set filter(DiscoverFilter val) {
    _filter = val;
    notifyListeners();
  }

  set birthday(bool val) {
    if (_birthday = val) return;
    _birthday = val;
    notifyListeners();
  }
}

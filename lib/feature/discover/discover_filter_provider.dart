import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';

final discoverFilterProvider =
    NotifierProvider<DiscoverFilterNotifier, DiscoverFilter>(
  DiscoverFilterNotifier.new,
);

class DiscoverFilterNotifier extends Notifier<DiscoverFilter> {
  @override
  DiscoverFilter build() {
    final options = ref.watch(persistenceProvider.select((s) => s.options));

    return DiscoverFilter(
      options.defaultDiscoverType,
      options.defaultDiscoverSort,
    );
  }

  @override
  DiscoverFilter get state => super.state;

  @override
  set state(DiscoverFilter newState) => super.state = newState;

  DiscoverFilter update(DiscoverFilter Function(DiscoverFilter) callback) =>
      super.state = callback(state);
}

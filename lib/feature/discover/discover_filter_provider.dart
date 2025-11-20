import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';

final discoverFilterProvider = NotifierProvider<DiscoverFilterNotifier, DiscoverFilter>(
  DiscoverFilterNotifier.new,
);

class DiscoverFilterNotifier extends Notifier<DiscoverFilter> {
  @override
  DiscoverFilter build() {
    final mediaFilter = ref.watch(persistenceProvider.select((s) => s.discoverMediaFilter));

    final discoverType = ref.watch(persistenceProvider.select((s) => s.options.discoverType));

    return DiscoverFilter(discoverType, mediaFilter);
  }

  @override
  DiscoverFilter get state => super.state;

  @override
  set state(DiscoverFilter newState) => super.state = newState;

  DiscoverFilter update(DiscoverFilter Function(DiscoverFilter) callback) =>
      super.state = callback(state);
}

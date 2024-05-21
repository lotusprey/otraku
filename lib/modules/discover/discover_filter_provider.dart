import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/discover/discover_models.dart';

final discoverFilterProvider =
    NotifierProvider<DiscoverFilterNotifier, DiscoverFilter>(
  DiscoverFilterNotifier.new,
);

class DiscoverFilterNotifier extends Notifier<DiscoverFilter> {
  @override
  DiscoverFilter build() => DiscoverFilter(Persistence().defaultDiscoverType);

  @override
  DiscoverFilter get state => super.state;

  @override
  set state(DiscoverFilter newState) => super.state = newState;

  DiscoverFilter update(DiscoverFilter Function(DiscoverFilter) callback) =>
      super.state = callback(state);
}

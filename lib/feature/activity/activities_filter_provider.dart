import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';

final activitiesFilterProvider = NotifierProvider.autoDispose
    .family<ActivitiesFilterNotifier, ActivitiesFilter, int?>(
  ActivitiesFilterNotifier.new,
);

class ActivitiesFilterNotifier
    extends AutoDisposeFamilyNotifier<ActivitiesFilter, int?> {
  @override
  ActivitiesFilter build(arg) => arg == null
      ? ref.watch(persistenceProvider.select((s) => s.homeActivitiesFilter))
      : UserActivitiesFilter(ActivityType.values, arg);

  @override
  set state(ActivitiesFilter newState) {
    switch (state) {
      case HomeActivitiesFilter homeActivitiesFilter:
        ref
            .read(persistenceProvider.notifier)
            .setHomeActivitiesFilter(homeActivitiesFilter);
      case UserActivitiesFilter _:
        super.state = newState;
    }
  }
}

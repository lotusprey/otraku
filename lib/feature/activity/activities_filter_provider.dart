import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';

final activitiesFilterProvider =
    NotifierProvider.autoDispose.family<ActivitiesFilterNotifier, ActivitiesFilter, ActivitiesTag>(
  ActivitiesFilterNotifier.new,
);

class ActivitiesFilterNotifier extends Notifier<ActivitiesFilter> {
  ActivitiesFilterNotifier(this.arg);

  final ActivitiesTag arg;

  @override
  ActivitiesFilter build() => switch (arg) {
        HomeActivitiesTag _ => ref.watch(
            persistenceProvider.select((s) => s.homeActivitiesFilter),
          ),
        UserActivitiesTag(:final userId) => UserActivitiesFilter(
            userId,
            ActivityType.values,
          ),
        MediaActivitiesTag(:final mediaId) => MediaActivitiesFilter(mediaId, false),
      };

  @override
  set state(ActivitiesFilter newState) {
    if (state == newState) return;

    switch (newState) {
      case HomeActivitiesFilter homeActivitiesFilter:
        ref.read(persistenceProvider.notifier).setHomeActivitiesFilter(homeActivitiesFilter);
      case UserActivitiesFilter _ || MediaActivitiesFilter _:
        super.state = newState;
    }
  }
}

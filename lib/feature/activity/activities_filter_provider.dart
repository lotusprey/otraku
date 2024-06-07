import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/feature/activity/activity_model.dart';

final activitiesFilterProvider = NotifierProvider.autoDispose
    .family<ActivitiesFilterNotifier, ActivitiesFilter, int>(
  ActivitiesFilterNotifier.new,
);

class ActivitiesFilterNotifier
    extends AutoDisposeFamilyNotifier<ActivitiesFilter, int> {
  @override
  ActivitiesFilter build(arg) => arg == homeFeedId
      ? HomeActivitiesFilter(
          Persistence()
              .feedActivityFilters
              .map((f) => ActivityType.values[f])
              .toList(),
          Persistence().feedOnFollowing,
          Persistence().viewerActivitiesInFeed,
        )
      : UserActivitiesFilter(ActivityType.values, arg);

  @override
  set state(ActivitiesFilter newState) {
    super.state = newState;

    switch (state) {
      case HomeActivitiesFilter f:
        Persistence().feedActivityFilters =
            f.typeIn.map((t) => t.index).toList();
        Persistence().feedOnFollowing = f.onFollowing;
        Persistence().viewerActivitiesInFeed = f.withViewerActivities;
      case UserActivitiesFilter _:
        return;
    }
  }
}

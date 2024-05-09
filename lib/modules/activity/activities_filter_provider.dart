import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/activity/activity_models.dart';

final activitiesFilterProvider = NotifierProvider.autoDispose
    .family<ActivitiesFilterNotifier, ActivitiesFilter, int>(
  ActivitiesFilterNotifier.new,
);

class ActivitiesFilterNotifier
    extends AutoDisposeFamilyNotifier<ActivitiesFilter, int> {
  @override
  ActivitiesFilter build(arg) => arg == homeFeedId
      ? HomeActivityFilter(
          Options()
              .feedActivityFilters
              .map((f) => ActivityType.values[f])
              .toList(),
          Options().feedOnFollowing,
          Options().viewerActivitiesInFeed,
        )
      : UserActivityFilter(ActivityType.values, arg);

  @override
  set state(ActivitiesFilter newState) {
    super.state = newState;

    switch (state) {
      case HomeActivityFilter f:
        Options().feedActivityFilters = f.typeIn.map((t) => t.index).toList();
        Options().feedOnFollowing = f.onFollowing;
        Options().viewerActivitiesInFeed = f.withViewerActivities;
      case UserActivityFilter _:
        return;
    }
  }
}

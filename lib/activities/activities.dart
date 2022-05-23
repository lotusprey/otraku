import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/activities/activity.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/settings.dart';

final activityFilterProvider = StateNotifierProvider.autoDispose
    .family<ActivityFilterNotifier, ActivityFilter, int?>(
  (ref, userId) {
    var typeIn = ActivityType.values;
    bool? onFollowing;

    if (userId == null) {
      onFollowing = Settings().feedOnFollowing;
      typeIn = Settings()
          .feedActivityFilters
          .map((e) => ActivityType.values.elementAt(e))
          .toList();
    }

    return ActivityFilterNotifier(typeIn, onFollowing);
  },
);

final activitiesProvider = StateNotifierProvider.autoDispose
    .family<ActivitiesNotifier, AsyncValue<Pagination<Activity>>, int?>(
  (ref, userId) {
    if (userId == null) ref.keepAlive();

    return ActivitiesNotifier(
      userId: userId,
      viewerId: Settings().id!,
      filter: ref.watch(activityFilterProvider(userId)),
    );
  },
);

class ActivitiesNotifier
    extends StateNotifier<AsyncValue<Pagination<Activity>>> {
  ActivitiesNotifier({
    required this.userId,
    required this.viewerId,
    required this.filter,
  }) : super(const AsyncValue.loading()) {
    fetch();
  }

  final int? userId;
  final int viewerId;
  final ActivityFilter filter;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.activities, {
        'page': value.next,
        'typeIn': filter.typeIn.map((t) => t.name).toList(),
        if (userId != null) ...{
          'userId': userId,
        } else ...{
          'isFollowing': filter.onFollowing,
          'hasRepliesOrTypeText': (filter.onFollowing ?? true) ? null : true,
        },
      });

      final items = <Activity>[];
      for (final a in data['Page']['activities']) {
        final item = Activity.maybe(a, viewerId);
        if (item != null) items.add(item);
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }

  /// Deletes an activity.
  Future<void> delete(int activityId) async {
    Api.get(GqlMutation.deleteActivity, {'id': activityId}).then((_) {
      if (!state.hasValue) return;
      final value = state.value!;

      for (int i = 0; i < value.items.length; i++)
        if (value.items[i].id == activityId) {
          state = AsyncData(value.copyWith([...value.items..removeAt(i)]));
          return;
        }
    }).catchError((_) {});
  }
}

class ActivityFilterNotifier extends StateNotifier<ActivityFilter> {
  ActivityFilterNotifier(List<ActivityType> typeIn, bool? onFollowing)
      : super(ActivityFilter(typeIn, onFollowing));

  void update(List<ActivityType> typeIn, bool? onFollowing) {
    state = state.onFollowing == null
        ? ActivityFilter(typeIn, null)
        : ActivityFilter(typeIn, onFollowing ?? state.onFollowing);

    Settings().feedActivityFilters = typeIn.map((e) => e.index).toList();
    if (onFollowing != null) Settings().feedOnFollowing = onFollowing;
  }
}

class ActivityFilter {
  const ActivityFilter(this.typeIn, this.onFollowing);

  final List<ActivityType> typeIn;
  final bool? onFollowing;
}

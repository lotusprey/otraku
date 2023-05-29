import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/activity/activity_models.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/options.dart';

final activitiesProvider = StateNotifierProvider.autoDispose
    .family<ActivitiesNotifier, AsyncValue<Paged<Activity>>, int?>(
  (ref, userId) => ActivitiesNotifier(
    viewerId: Options().id!,
    filter: ref.watch(activityFilterProvider(userId)),
    shouldLoad:
        userId != null || ref.watch(homeProvider.select((s) => s.didLoadFeed)),
  ),
);

final activityFilterProvider =
    StateProvider.autoDispose.family<ActivitiesFilter, int?>(
  (ref, userId) => userId == null
      ? HomeActivitiesFilter(
          ActivityType.values,
          Options().feedOnFollowing,
          Options().viewerActivitiesInFeed,
        )
      : UserActivitiesFilter(ActivityType.values, userId),
);

class ActivitiesNotifier extends StateNotifier<AsyncValue<Paged<Activity>>> {
  ActivitiesNotifier({
    required this.viewerId,
    required this.filter,
    required bool shouldLoad,
  }) : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final int viewerId;
  final ActivitiesFilter filter;
  int _lastCreatedAt = DateTime.now().millisecondsSinceEpoch;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.activities, {
        'typeIn': filter.typeIn.map((t) => t.name).toList(),
        ...switch (filter) {
          HomeActivitiesFilter filter => {
              'isFollowing': filter.onFollowing,
              if (!filter.withViewerActivities) 'userIdNot': viewerId,
              if (!filter.onFollowing) 'hasRepliesOrText': true,
              if (value.items.isNotEmpty) 'createdBefore': _lastCreatedAt,
            },
          UserActivitiesFilter filter => {
              'userId': filter.userId,
              'page': value.next,
            },
        },
      });

      final items = <Activity>[];
      for (final a in data['Page']['activities']) {
        final item = Activity.maybe(a, viewerId);
        if (item != null) items.add(item);
      }

      if (data['Page']['activities'].isNotEmpty) {
        _lastCreatedAt = data['Page']['activities'].last['createdAt'];
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }

  /// Deserializes [map] and inserts it at the beginning.
  void insertActivity(Map<String, dynamic> map, int viewerId) {
    if (!state.hasValue) return;
    final value = state.value!;

    final activity = Activity.maybe(map, viewerId);
    if (activity == null) return;

    state = AsyncData(Paged(
      items: [activity, ...value.items],
      hasNext: value.hasNext,
      next: value.next,
    ));
  }

  /// Deserializes [map] and replaces an existing activity with another one.
  void replaceActivity(Map<String, dynamic> map) {
    if (!state.hasValue) return;
    final value = state.value!;

    final activity = Activity.maybe(map, viewerId);
    if (activity == null) return;

    for (int i = 0; i < value.items.length; i++) {
      if (value.items[i].id == activity.id) {
        value.items[i] = activity;
        state = AsyncData(Paged(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        return;
      }
    }
  }

  /// Updates an existing activity with another one.
  void updateActivity(Activity activity) {
    if (!state.hasValue) return;
    final value = state.value!;

    for (int i = 0; i < value.items.length; i++) {
      if (value.items[i].id == activity.id) {
        value.items[i] = activity;
        state = AsyncData(Paged(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        return;
      }
    }
  }

  /// Removes an already deleted activity.
  void remove(int activityId) {
    if (!state.hasValue) return;
    final value = state.value!;

    for (int i = 0; i < value.items.length; i++) {
      if (value.items[i].id == activityId) {
        value.items.removeAt(i);
        state = AsyncData(Paged(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        return;
      }
    }
  }

  /// Updates an already pinned/unpinned activity.
  void togglePin(int activityId) {
    if (!state.hasValue) return;
    final value = state.value!;

    for (int i = 0; i < value.items.length; i++) {
      if (value.items[i].id == activityId) {
        // If the activity was pinned, and there had already
        // been a pinned activity, unpin the old one.
        if (value.items[i].isPinned && value.items[0].isPinned && i > 0) {
          value.items[0].isPinned = false;
        }

        state = AsyncData(Paged(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        return;
      }
    }
  }
}

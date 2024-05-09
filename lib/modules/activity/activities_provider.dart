import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/activity/activities_filter_provider.dart';
import 'package:otraku/modules/activity/activity_models.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/modules/viewer/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/options.dart';

final activitiesProvider = AsyncNotifierProvider.autoDispose
    .family<ActivitiesNotifier, Paged<Activity>, int>(
  ActivitiesNotifier.new,
);

class ActivitiesNotifier
    extends AutoDisposeFamilyAsyncNotifier<Paged<Activity>, int> {
  late int viewerId;
  late ActivitiesFilter filter;
  int _lastCreatedAt = DateTime.now().millisecondsSinceEpoch;

  @override
  FutureOr<Paged<Activity>> build(arg) async {
    if (arg == homeFeedId) {
      ref.keepAlive();
    }

    viewerId = Options().id!;
    filter = ref.watch(activitiesFilterProvider(arg));
    return await _fetch(const Paged());
  }

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const Paged();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<Paged<Activity>> _fetch(Paged<Activity> oldState) async {
    final data = await Api.get(GqlQuery.activityPage, {
      'typeIn': filter.typeIn.map((t) => t.name).toList(),
      ...switch (filter) {
        HomeActivityFilter filter => {
            'isFollowing': filter.onFollowing,
            if (!filter.withViewerActivities) 'userIdNot': viewerId,
            if (!filter.onFollowing) 'hasRepliesOrText': true,
            if (oldState.items.isNotEmpty) 'createdBefore': _lastCreatedAt,
          },
        UserActivityFilter filter => {
            'userId': filter.userId,
            'page': oldState.next,
          },
      },
    });

    final items = <Activity>[];
    for (final a in data['Page']['activities']) {
      final item = Activity.maybe(a, viewerId, Options().imageQuality);
      if (item != null) items.add(item);
    }

    if (data['Page']['activities'].isNotEmpty) {
      _lastCreatedAt = data['Page']['activities'].last['createdAt'];
    }

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    );
  }

  /// Deserializes [map] and inserts it at the beginning.
  void insertActivity(Map<String, dynamic> map, int viewerId) {
    if (!state.hasValue) return;
    final value = state.value!;

    final activity = Activity.maybe(map, viewerId, Options().imageQuality);
    if (activity == null) return;

    state = AsyncValue.data(Paged(
      items: [activity, ...value.items],
      hasNext: value.hasNext,
      next: value.next,
    ));
  }

  /// Deserializes [map] and replaces an existing activity with another one.
  void replaceActivity(Map<String, dynamic> map) {
    if (!state.hasValue) return;
    final value = state.value!;

    final activity = Activity.maybe(map, viewerId, Options().imageQuality);
    if (activity == null) return;

    for (int i = 0; i < value.items.length; i++) {
      if (value.items[i].id == activity.id) {
        value.items[i] = activity;
        state = AsyncValue.data(Paged(
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
        state = AsyncValue.data(Paged(
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
        state = AsyncValue.data(Paged(
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

        state = AsyncValue.data(Paged(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        return;
      }
    }
  }
}

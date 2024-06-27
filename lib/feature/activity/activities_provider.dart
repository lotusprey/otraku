import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/activity/activities_filter_provider.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/model/paged.dart';
import 'package:otraku/util/extensions.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/util/persistence.dart';

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

    viewerId = Persistence().id!;
    filter = ref.watch(activitiesFilterProvider(arg));
    return await _fetch(const Paged());
  }

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const Paged();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<Paged<Activity>> _fetch(Paged<Activity> oldState) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.activityPage,
      {
        'typeIn': filter.typeIn.map((t) => t.name).toList(),
        ...switch (filter) {
          HomeActivitiesFilter filter => {
              'isFollowing': filter.onFollowing,
              if (!filter.withViewerActivities) 'userIdNot': viewerId,
              if (!filter.onFollowing) 'hasRepliesOrText': true,
              if (oldState.items.isNotEmpty) 'createdBefore': _lastCreatedAt,
            },
          UserActivitiesFilter filter => {
              'userId': filter.userId,
              'page': oldState.next,
            },
        },
      },
    );

    final items = <Activity>[];
    for (final a in data['Page']['activities']) {
      final item = Activity.maybe(a, viewerId, Persistence().imageQuality);
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

  void prepend(Map<String, dynamic> map) {
    final value = state.valueOrNull;
    if (value == null) return;

    final activity = Activity.maybe(map, viewerId, Persistence().imageQuality);
    if (activity == null) return;

    state = AsyncValue.data(Paged(
      items: [activity, ...value.items],
      hasNext: value.hasNext,
      next: value.next,
    ));
  }

  void replace(Activity activity) {
    final value = state.valueOrNull;
    if (value == null) return;

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

  Future<Object?> toggleLike(Activity activity) async {
    final err = await ref.read(repositoryProvider).request(
      GqlMutation.toggleLike,
      {'id': activity.id, 'type': 'ACTIVITY'},
    ).getErrorOrNull();

    if (err != null) return err;

    replace(activity);
    return null;
  }

  Future<Object?> toggleSubscription(Activity activity) async {
    final err = await ref.read(repositoryProvider).request(
      GqlMutation.toggleActivitySubscription,
      {'id': activity.id, 'subscribe': activity.isSubscribed},
    ).getErrorOrNull();

    if (err != null) return err;

    replace(activity);
    return null;
  }

  Future<Object?> togglePin(Activity activity) async {
    final err = await ref.read(repositoryProvider).request(
      GqlMutation.toggleActivityPin,
      {'id': activity.id, 'pinned': activity.isPinned},
    ).getErrorOrNull();

    if (err != null) return err;

    final value = state.valueOrNull;
    if (value == null) return null;

    for (int i = 0; i < value.items.length; i++) {
      if (value.items[i].id == activity.id) {
        // Unpin previously pinned activity.
        if (value.items.length > 1) {
          value.items[0].isPinned = false;
        }

        // Move newly pinned activity to the top.
        for (int j = i - 1; j >= 0; j--) {
          value.items[j + 1] = value.items[j];
        }
        value.items[0] = activity;

        state = AsyncValue.data(Paged(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        break;
      }
    }

    return null;
  }

  Future<Object?> remove(Activity activity) async {
    final err = await ref.read(repositoryProvider).request(
      GqlMutation.deleteActivity,
      {'id': activity.id},
    ).getErrorOrNull();

    if (err != null) return err;

    final value = state.valueOrNull;
    if (value == null) return null;

    for (int i = 0; i < value.items.length; i++) {
      if (value.items[i].id == activity.id) {
        value.items.removeAt(i);

        state = AsyncValue.data(Paged(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        break;
      }
    }

    return null;
  }
}

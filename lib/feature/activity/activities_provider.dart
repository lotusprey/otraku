import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/activity/activities_filter_provider.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/util/graphql.dart';

final activitiesProvider = AsyncNotifierProvider.autoDispose
    .family<ActivitiesNotifier, Paged<Activity>, int>(
  ActivitiesNotifier.new,
);

class ActivitiesNotifier
    extends AutoDisposeFamilyAsyncNotifier<Paged<Activity>, int> {
  // Used to skip activities when fetching outdated pages.
  int? _lastId;
  int? _viewerId;
  late ActivitiesFilter _filter;

  @override
  FutureOr<Paged<Activity>> build(arg) async {
    if (arg == homeFeedId) {
      ref.keepAlive();
    }

    _lastId = null;
    _filter = ref.watch(activitiesFilterProvider(arg));
    _viewerId = ref.watch(
      persistenceProvider.select((s) => s.accountGroup.account?.id),
    );

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
        'typeIn': _filter.typeIn.map((t) => t.name).toList(),
        ...switch (_filter) {
          HomeActivitiesFilter filter => {
              'page': oldState.next,
              'isFollowing': filter.onFollowing,
              if (!filter.withViewerActivities && _viewerId != null)
                'userIdNot': _viewerId,
              if (!filter.onFollowing) 'hasRepliesOrText': true,
            },
          UserActivitiesFilter filter => {
              'userId': filter.userId,
              'page': oldState.next,
            },
        },
      },
    );

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    final items = <Activity>[];
    for (final a in data['Page']['activities']) {
      if (_lastId != null && a['id'] >= _lastId) continue;

      final item = Activity.maybe(a, _viewerId, imageQuality);
      if (item != null) items.add(item);
    }

    if (data['Page']['activities'].isNotEmpty) {
      _lastId = data['Page']['activities'].last['id'];
    }

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    );
  }

  void prepend(Map<String, dynamic> map) {
    final value = state.valueOrNull;
    if (value == null) return;

    final activity = Activity.maybe(
      map,
      _viewerId,
      ref.read(persistenceProvider).options.imageQuality,
    );
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

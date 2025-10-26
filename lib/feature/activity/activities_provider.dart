import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/activity/activities_filter_provider.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/util/graphql.dart';

final activitiesProvider =
    AsyncNotifierProvider.autoDispose.family<ActivitiesNotifier, Paged<Activity>, ActivitiesTag>(
  ActivitiesNotifier.new,
);

class ActivitiesNotifier extends AsyncNotifier<Paged<Activity>> {
  ActivitiesNotifier(this.arg);

  final ActivitiesTag arg;

  int? _viewerId;
  late ActivitiesFilter _filter;

  // Used to skip activities when fetching outdated pages.
  late int _lastCreatedAt;

  @override
  FutureOr<Paged<Activity>> build() {
    // The home feed and the media feeds are lazy-loaded. The home feed is never disposed,
    // while the media feeds are disposed only when the media page is popped.
    if (arg is HomeActivitiesTag || arg is MediaActivitiesTag) {
      ref.keepAlive();
    }

    _lastCreatedAt = DateTime.now().secondsSinceEpoch;
    _filter = ref.watch(activitiesFilterProvider(arg));
    _viewerId = ref.watch(viewerIdProvider);

    return _fetch(const Paged());
  }

  Future<void> fetch() async {
    final oldState = state.value ?? const Paged();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<Paged<Activity>> _fetch(Paged<Activity> oldState) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.activityPage,
      {'createdBefore': _lastCreatedAt + 1, ..._filter.toGraphQlVariables()},
    );

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;
    final lastId = oldState.items.isNotEmpty ? oldState.items.last.id : null;

    final items = <Activity>[];
    for (final a in data['Page']['activities']) {
      if (lastId != null && a['id'] >= lastId) continue;

      final item = Activity.maybe(a, _viewerId, imageQuality);
      if (item != null) items.add(item);
    }

    if (items.isNotEmpty) {
      _lastCreatedAt = items.last.createdAt.secondsSinceEpoch;
    }

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    );
  }

  void prepend(Map<String, dynamic> map) {
    final value = state.value;
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
    final value = state.value;
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

    final value = state.value;
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

    final value = state.value;
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

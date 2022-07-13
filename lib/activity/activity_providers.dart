import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/activity/activity_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/settings.dart';

/// Toggles an activity like and returns `true` if successful.
Future<bool> toggleActivityLike(Activity activity) async {
  try {
    await Api.get(GqlMutation.toggleLike, {
      'id': activity.id,
      'type': 'ACTIVITY',
    });
    return true;
  } catch (_) {
    return false;
  }
}

/// Toggles an activity subscription and returns `true` if successful.
Future<bool> toggleActivitySubscription(Activity activity) async {
  try {
    await Api.get(GqlMutation.toggleActivitySubscription, {
      'id': activity.id,
      'subscribe': activity.isSubscribed,
    });
    return true;
  } catch (_) {
    return false;
  }
}

/// Pins/Unpins an activity and returns the error if successful.
Future<Object?> toggleActivityPin(Activity activity) async {
  try {
    await Api.get(GqlMutation.toggleActivityPin, {
      'id': activity.id,
      'pinned': activity.isPinned,
    });
    return null;
  } catch (e) {
    return e;
  }
}

/// Toggles a reply like and returns `true` if successful.
Future<bool> toggleReplyLike(ActivityReply reply) async {
  try {
    await Api.get(GqlMutation.toggleLike, {
      'id': reply.id,
      'type': 'ACTIVITY_REPLY',
    });
    return true;
  } catch (_) {
    return false;
  }
}

/// Deletes an activity.
Future<bool> deleteActivity(int activityId) async {
  try {
    await Api.get(GqlMutation.deleteActivity, {'id': activityId});
    return true;
  } catch (_) {
    return false;
  }
}

final activityProvider = StateNotifierProvider.autoDispose
    .family<ActivityNotifier, AsyncValue<ActivityState>, int>(
  (ref, userId) => ActivityNotifier(userId, Settings().id!),
);

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
  (ref, userId) => ActivitiesNotifier(
    userId: userId,
    viewerId: Settings().id!,
    filter: ref.watch(activityFilterProvider(userId)),
  ),
);

class ActivityNotifier extends StateNotifier<AsyncValue<ActivityState>> {
  ActivityNotifier(this.userId, this.viewerId)
      : super(const AsyncValue.loading()) {
    fetch();
  }

  final int userId;
  final int viewerId;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final replies = state.value?.replies ?? Pagination();

      final data = await Api.get(GqlQuery.activity, {
        'id': userId,
        'page': replies.next,
        if (replies.next == 1) 'withActivity': true,
      });

      final items = <ActivityReply>[];
      for (final r in data['Page']['activityReplies']) {
        final item = ActivityReply.maybe(r);
        if (item != null) items.add(item);
      }

      final activity =
          state.value?.activity ?? Activity.maybe(data['Activity'], viewerId);
      if (activity == null) throw StateError('Could not parse activity');

      return ActivityState(
        activity,
        replies.append(
          items,
          data['Page']['pageInfo']['hasNextPage'] ?? false,
        ),
      );
    });
  }
}

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

  /// Replace an existing activity with another one.
  void replaceActivity(Activity activity) {
    if (!state.hasValue) return;
    final value = state.value!;

    for (int i = 0; i < value.items.length; i++)
      if (value.items[i].id == activity.id) {
        value.items[i] = activity;
        state = AsyncData(value.copyWith([...value.items]));
        return;
      }
  }

  /// Removes an already deleted activity.
  void delete(int activityId) {
    if (!state.hasValue) return;
    final value = state.value!;

    for (int i = 0; i < value.items.length; i++)
      if (value.items[i].id == activityId) {
        state = AsyncData(value.copyWith([...value.items..removeAt(i)]));
        return;
      }
  }

  /// Updates an already pinned/unpinned activity.
  void togglePin(int activityId) {
    if (!state.hasValue) return;
    final value = state.value!;

    for (int i = 0; i < value.items.length; i++)
      if (value.items[i].id == activityId) {
        // If the activity was pinned, and there had already
        // been a pinned activity, unpin the old one.
        if (value.items[i].isPinned && value.items[0].isPinned && i > 0)
          value.items[0].isPinned = false;

        state = AsyncData(value.copyWith([...value.items]));
        return;
      }
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/activity/activity_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/pagination.dart';
import 'package:otraku/utils/options.dart';

/// Toggles an activity like and returns an error if unsuccessful.
Future<Object?> toggleActivityLike(Activity activity) async {
  try {
    await Api.get(GqlMutation.toggleLike, {
      'id': activity.id,
      'type': 'ACTIVITY',
    });
    return null;
  } catch (e) {
    return e;
  }
}

/// Toggles an activity subscription and returns an error if unsuccessful.
Future<Object?> toggleActivitySubscription(Activity activity) async {
  try {
    await Api.get(GqlMutation.toggleActivitySubscription, {
      'id': activity.id,
      'subscribe': activity.isSubscribed,
    });
    return null;
  } catch (e) {
    return e;
  }
}

/// Pins/Unpins an activity and returns an error if unsuccessful.
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

/// Toggles a reply like and returns an error if unsuccessful.
Future<Object?> toggleReplyLike(ActivityReply reply) async {
  try {
    await Api.get(GqlMutation.toggleLike, {
      'id': reply.id,
      'type': 'ACTIVITY_REPLY',
    });
    return null;
  } catch (e) {
    return e;
  }
}

/// Deletes an activity and returns an error if unsuccessful.
Future<Object?> deleteActivity(int activityId) async {
  try {
    await Api.get(GqlMutation.deleteActivity, {'id': activityId});
    return null;
  } catch (e) {
    return e;
  }
}

/// Deletes an activity reply and returns an error if unsuccessful.
Future<Object?> deleteActivityReply(int replyId) async {
  try {
    await Api.get(GqlMutation.deleteActivityReply, {'id': replyId});
    return null;
  } catch (e) {
    return e;
  }
}

final activityProvider = StateNotifierProvider.autoDispose
    .family<ActivityNotifier, AsyncValue<ActivityState>, int>(
  (ref, userId) => ActivityNotifier(userId, Options().id!),
);

final activityFilterProvider = StateNotifierProvider.autoDispose
    .family<ActivityFilterNotifier, ActivityFilter, int?>(
  (ref, userId) {
    var typeIn = ActivityType.values;
    bool? onFollowing;

    if (userId == null) {
      onFollowing = Options().feedOnFollowing;
      typeIn = Options()
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
    viewerId: Options().id!,
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

  /// Deserializes [map] and replaces the current activity.
  void replaceActivity(Map<String, dynamic> map, int viewerId) {
    if (!state.hasValue) return;
    final value = state.value!;

    final activity = Activity.maybe(map, viewerId);
    if (activity == null) return;

    state = AsyncData(ActivityState(activity, value.replies));
  }

  /// Deserializes [map] and appends it at the end.
  void appendReply(Map<String, dynamic> map) {
    if (!state.hasValue) return;
    final value = state.value!;

    final reply = ActivityReply.maybe(map);
    if (reply == null) return;

    value.activity.replyCount++;
    state = AsyncData(ActivityState(
      value.activity,
      Pagination.from(
        items: [...value.replies.items, reply],
        hasNext: value.replies.hasNext,
        next: value.replies.next,
      ),
    ));
  }

  /// Replaces an existing reply with another one.
  void replaceReply(Map<String, dynamic> map) {
    if (!state.hasValue) return;
    final value = state.value!;

    final reply = ActivityReply.maybe(map);
    if (reply == null) return;

    for (int i = 0; i < value.replies.items.length; i++) {
      if (value.replies.items[i].id == reply.id) {
        value.replies.items[i] = reply;
        state = AsyncData(ActivityState(
          value.activity,
          Pagination.from(
            items: value.replies.items,
            hasNext: value.replies.hasNext,
            next: value.replies.next,
          ),
        ));
        return;
      }
    }
  }

  /// Removes an already deleted reply.
  void removeReply(int replyId) {
    if (!state.hasValue) return;
    final value = state.value!;

    for (int i = 0; i < value.replies.items.length; i++) {
      if (value.replies.items[i].id == replyId) {
        value.replies.items.removeAt(i);
        value.activity.replyCount--;

        state = AsyncData(ActivityState(
          value.activity,
          Pagination.from(
            items: value.replies.items,
            hasNext: value.replies.hasNext,
            next: value.replies.next,
          ),
        ));
        return;
      }
    }
  }
}

class ActivitiesNotifier
    extends StateNotifier<AsyncValue<Pagination<Activity>>> {
  ActivitiesNotifier({
    required this.userId,
    required this.viewerId,
    required this.filter,
  }) : super(const AsyncValue.loading()) {
    /// The home feed will be lazily-loaded by [homeProvider].
    if (userId != null) fetch();
  }

  /// [userId] being `null` means that this notifier handles the home feed.
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

  /// Deserializes [map] and inserts it at the beginning.
  void insertActivity(Map<String, dynamic> map, int viewerId) {
    if (!state.hasValue) return;
    final value = state.value!;

    final activity = Activity.maybe(map, viewerId);
    if (activity == null) return;

    state = AsyncData(Pagination.from(
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
        state = AsyncData(Pagination.from(
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
        state = AsyncData(Pagination.from(
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
        state = AsyncData(Pagination.from(
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

        state = AsyncData(Pagination.from(
          items: value.items,
          hasNext: value.hasNext,
          next: value.next,
        ));
        return;
      }
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

    if (onFollowing == null) return;
    Options().feedActivityFilters = typeIn.map((e) => e.index).toList();
    Options().feedOnFollowing = onFollowing;
  }
}

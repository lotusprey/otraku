import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/activity/activity_models.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/options.dart';

final activitiesProvider = StateNotifierProvider.autoDispose
    .family<ActivitiesNotifier, AsyncValue<Paged<Activity>>, int?>(
  (ref, userId) => ActivitiesNotifier(
    userId: userId,
    viewerId: Options().id!,
    filter: ref.watch(activityFilterProvider(userId)),
    shouldLoad:
        userId != null || ref.watch(homeProvider.select((s) => s.didLoadFeed)),
  ),
);

final activityFilterProvider = StateNotifierProvider.autoDispose
    .family<ActivityFilterNotifier, ActivityFilter, int?>(
  (ref, userId) {
    var typeIn = ActivityType.values;
    FeedFilter? feedFilter;

    if (userId == null) {
      feedFilter = FeedFilter(
        Options().feedOnFollowing,
        Options().viewerActivitiesInFeed,
      );
      typeIn = Options()
          .feedActivityFilters
          .map((e) => ActivityType.values.elementAt(e))
          .toList();
    }

    return ActivityFilterNotifier(typeIn, feedFilter);
  },
);

class ActivitiesNotifier extends StateNotifier<AsyncValue<Paged<Activity>>> {
  ActivitiesNotifier({
    required this.userId,
    required this.viewerId,
    required this.filter,
    required bool shouldLoad,
  }) : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  /// [userId] being `null` means that this notifier handles the home feed.
  final int? userId;
  final int viewerId;
  final ActivityFilter filter;

  /// [_lastCreatedAt] is used to track pages, instead of the next page value
  /// of the state. This prevents duplicates when more pages are loaded,
  /// as new activities are created often.
  int? _lastCreatedAt;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.activities, {
        'typeIn': filter.typeIn.map((t) => t.name).toList(),
        if (userId != null) 'userId': userId,
        if (filter.feedFilter != null) ...{
          'isFollowing': filter.feedFilter!.onFollowing,
          if (!filter.feedFilter!.withViewerActivities) 'userIdNot': viewerId,
          if (!filter.feedFilter!.onFollowing) 'hasRepliesOrText': true,
        },
        if (_lastCreatedAt != null) 'createdBefore': _lastCreatedAt!
      });

      final items = <Activity>[];
      for (final a in data['Page']['activities']) {
        final item = Activity.maybe(a, viewerId);
        if (item != null) items.add(item);
      }

      if (data['Page']['activities']?.isNotEmpty ?? false) {
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

class ActivityFilterNotifier extends StateNotifier<ActivityFilter> {
  ActivityFilterNotifier(List<ActivityType> typeIn, FeedFilter? feedFilter)
      : super(ActivityFilter(typeIn, feedFilter));

  void update(
    List<ActivityType> typeIn,
    bool? onFollowing,
    bool? withViewerActivities,
  ) {
    state = state.feedFilter == null
        ? ActivityFilter(typeIn, null)
        : ActivityFilter(
            typeIn,
            FeedFilter(
              onFollowing ?? state.feedFilter!.onFollowing,
              withViewerActivities ?? state.feedFilter!.withViewerActivities,
            ),
          );

    if (state.feedFilter == null) return;
    Options().feedActivityFilters = typeIn.map((e) => e.index).toList();
    Options().feedOnFollowing = state.feedFilter!.onFollowing;
    Options().viewerActivitiesInFeed = state.feedFilter!.withViewerActivities;
  }
}

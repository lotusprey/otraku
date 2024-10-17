import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/util/paged.dart';

final activityProvider = AsyncNotifierProvider.autoDispose
    .family<ActivityNotifier, ExpandedActivity, int>(
  ActivityNotifier.new,
);

class ActivityNotifier
    extends AutoDisposeFamilyAsyncNotifier<ExpandedActivity, int> {
  int? _viewerId;

  @override
  FutureOr<ExpandedActivity> build(arg) async {
    _viewerId = ref.watch(
      persistenceProvider.select((s) => s.accountGroup.account?.id),
    );

    return await _fetch(null);
  }

  Future<void> fetch() async {
    if (!(state.valueOrNull?.replies.hasNext ?? true)) return;
    state = await AsyncValue.guard(() => _fetch(state.valueOrNull));
  }

  Future<ExpandedActivity> _fetch(ExpandedActivity? oldState) async {
    final replies = oldState?.replies ?? const Paged();

    final data = await ref.read(repositoryProvider).request(GqlQuery.activity, {
      'id': arg,
      'page': replies.next,
      if (replies.next == 1) 'withActivity': true,
    });

    final items = <ActivityReply>[];
    for (final r in data['Page']['activityReplies']) {
      final item = ActivityReply.maybe(r);
      if (item != null) items.add(item);
    }

    final activity = oldState?.activity ??
        Activity.maybe(
          data['Activity'],
          _viewerId,
          ref.read(persistenceProvider).options.imageQuality,
        );
    if (activity == null) throw StateError('Could not parse activity');

    return ExpandedActivity(
      activity,
      replies.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      ),
    );
  }

  void replace(Activity activity) {
    final value = state.valueOrNull;
    if (value == null) return;

    state = AsyncValue.data(ExpandedActivity(activity, value.replies));
  }

  void appendReply(Map<String, dynamic> map) {
    final value = state.valueOrNull;
    if (value == null) return;

    final reply = ActivityReply.maybe(map);
    if (reply == null) return;

    value.activity.replyCount++;
    state = AsyncValue.data(ExpandedActivity(
      value.activity,
      Paged(
        items: [...value.replies.items, reply],
        hasNext: value.replies.hasNext,
        next: value.replies.next,
      ),
    ));
  }

  void replaceReply(Map<String, dynamic> map) {
    final value = state.valueOrNull;
    if (value == null) return;

    final reply = ActivityReply.maybe(map);
    if (reply == null) return;

    for (int i = 0; i < value.replies.items.length; i++) {
      if (value.replies.items[i].id == reply.id) {
        value.replies.items[i] = reply;
        state = AsyncValue.data(ExpandedActivity(
          value.activity,
          Paged(
            items: value.replies.items,
            hasNext: value.replies.hasNext,
            next: value.replies.next,
          ),
        ));
        return;
      }
    }
  }

  Future<Object?> toggleLike() {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleLike,
      {'id': arg, 'type': 'ACTIVITY'},
    ).getErrorOrNull();
  }

  Future<Object?> toggleSubscription() {
    final isSubscribed = state.valueOrNull?.activity.isSubscribed;
    if (isSubscribed == null) return Future.value();

    return ref.read(repositoryProvider).request(
      GqlMutation.toggleActivitySubscription,
      {'id': arg, 'subscribe': isSubscribed},
    ).getErrorOrNull();
  }

  Future<Object?> togglePin() {
    final isPinned = state.valueOrNull?.activity.isPinned;
    if (isPinned == null) return Future.value();

    return ref.read(repositoryProvider).request(
      GqlMutation.toggleActivityPin,
      {'id': arg, 'pinned': isPinned},
    ).getErrorOrNull();
  }

  Future<Object?> toggleReplyLike(int replyId) {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleLike,
      {'id': replyId, 'type': 'ACTIVITY_REPLY'},
    ).getErrorOrNull();
  }

  Future<Object?> remove() {
    return ref.read(repositoryProvider).request(
      GqlMutation.deleteActivity,
      {'id': arg},
    ).getErrorOrNull();
  }

  Future<Object?> removeReply(int replyId) async {
    final value = state.valueOrNull;
    if (value == null) return Future.value();

    final err = await ref.read(repositoryProvider).request(
      GqlMutation.deleteActivityReply,
      {'id': replyId},
    ).getErrorOrNull();

    if (err != null) return err;

    for (int i = 0; i < value.replies.items.length; i++) {
      if (value.replies.items[i].id == replyId) {
        value.replies.items.removeAt(i);
        value.activity.replyCount--;

        state = AsyncValue.data(ExpandedActivity(
          value.activity,
          Paged(
            items: value.replies.items,
            hasNext: value.replies.hasNext,
            next: value.replies.next,
          ),
        ));
        break;
      }
    }

    return null;
  }
}

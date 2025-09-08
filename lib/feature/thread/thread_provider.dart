import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/thread/thread_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final threadProvider = AsyncNotifierProvider.autoDispose.family<ThreadNotifier, Thread, int>(
  ThreadNotifier.new,
);

class ThreadNotifier extends AutoDisposeFamilyAsyncNotifier<Thread, int> {
  @override
  FutureOr<Thread> build(int arg) async {
    final data =
        await ref.read(repositoryProvider).request(GqlQuery.thread, {'id': arg, 'withInfo': true});

    final options = ref.watch(persistenceProvider.select((s) => s.options));

    return Thread(data, options.imageQuality);
  }

  Future<void> changePage(int page) async {
    final value = state.valueOrNull;
    if (value == null) return;

    state = const AsyncValue<Thread>.loading().copyWithPrevious(
      state.whenData((data) => data.withChangingCommentPage(page)),
    );

    final data =
        await ref.read(repositoryProvider).request(GqlQuery.thread, {'id': arg, 'page': page});

    state = AsyncValue.data(value.withChangedCommentPage(data));
  }

  void appendComment(Map<String, dynamic> map, int? parentCommentId) {
    final value = state.valueOrNull;
    if (value == null) return;

    // If there's a new thread comment, it can only appear on the last page.
    if (parentCommentId == null && value.commentPage != value.totalCommentPages) {
      return;
    }

    state = AsyncValue.data(value.withAppendedComment(map, parentCommentId));
  }

  Future<Object?> toggleThreadLike() {
    final value = state.valueOrNull;
    if (value == null) return Future.value(null);

    return ref.read(repositoryProvider).request(
      GqlMutation.toggleLike,
      {'id': value.info.id, 'type': 'THREAD'},
    ).getErrorOrNull();
  }

  Future<Object?> toggleCommentLike(int commentId) {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleLike,
      {'id': commentId, 'type': 'THREAD_COMMENT'},
    ).getErrorOrNull();
  }

  Future<Object?> toggleThreadSubscription() async {
    final value = state.valueOrNull;
    if (value == null) return null;

    final info = value.info;
    final prevIsSubscribed = info.isSubscribed;
    info.isSubscribed = !prevIsSubscribed;

    final err = await ref.read(repositoryProvider).request(
      GqlMutation.toggleThreadSubscription,
      {'id': info.id, 'subscribe': info.isSubscribed},
    ).getErrorOrNull();

    if (err != null) {
      info.isSubscribed = prevIsSubscribed;
      return err;
    }

    return null;
  }

  Future<Object?> delete() =>
      ref.read(repositoryProvider).request(GqlMutation.deleteThread, {'id': arg}).getErrorOrNull();
}

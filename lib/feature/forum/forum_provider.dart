import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/forum/forum_filter_model.dart';
import 'package:otraku/feature/forum/forum_filter_provider.dart';
import 'package:otraku/feature/forum/forum_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/util/paged.dart';

final forumProvider =
    AsyncNotifierProvider.autoDispose<ForumNotifier, Paged<ThreadItem>>(
  ForumNotifier.new,
);

class ForumNotifier extends AutoDisposeAsyncNotifier<Paged<ThreadItem>> {
  late ForumFilter _filter;

  @override
  FutureOr<Paged<ThreadItem>> build() {
    _filter = ref.watch(forumFilterProvider);
    return _fetch(const Paged());
  }

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const Paged();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<Paged<ThreadItem>> _fetch(Paged<ThreadItem> oldState) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.threadPage,
      {'page': oldState.next, ..._filter.toGraphQlVariables()},
    );

    final items = <ThreadItem>[];
    for (final t in data['Page']['threads']) {
      items.add(ThreadItem(t));
    }

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    );
  }
}

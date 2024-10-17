import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/notification/notifications_filter_model.dart';
import 'package:otraku/feature/notification/notifications_filter_provider.dart';
import 'package:otraku/feature/notification/notifications_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final notificationsProvider = AsyncNotifierProvider.autoDispose<
    NotificationsNotifier, PagedWithTotal<SiteNotification>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<PagedWithTotal<SiteNotification>> {
  late NotificationsFilter filter;

  @override
  FutureOr<PagedWithTotal<SiteNotification>> build() async {
    filter = ref.watch(notificationsFilterProvider);
    return await _fetch(const PagedWithTotal());
  }

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const PagedWithTotal();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<PagedWithTotal<SiteNotification>> _fetch(
    PagedWithTotal<SiteNotification> oldState,
  ) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.notifications,
      {
        'page': oldState.next,
        if (filter == NotificationsFilter.all) ...{
          'withCount': true,
          'resetCount': true,
        } else
          'filter': filter.vars,
      },
    );

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    int? unreadCount;
    if (filter.index < 1) {
      unreadCount = data['Viewer']['unreadNotificationCount'] ?? 0;
    }

    final items = <SiteNotification>[];
    for (final n in data['Page']['notifications']) {
      final item = SiteNotification.maybe(n, imageQuality);
      if (item != null) items.add(item);
    }

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
      unreadCount,
    );
  }
}

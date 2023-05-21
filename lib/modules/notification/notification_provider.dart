import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/notification/notification_model.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';

final notificationFilterProvider = StateProvider.autoDispose(
  (ref) => NotificationFilterType.all,
);

final notificationsProvider = StateNotifierProvider.autoDispose<
    NotificationsNotifier, AsyncValue<PagedWithTotal<SiteNotification>>>(
  (ref) => NotificationsNotifier(ref.watch(notificationFilterProvider)),
);

class NotificationsNotifier
    extends StateNotifier<AsyncValue<PagedWithTotal<SiteNotification>>> {
  NotificationsNotifier(this.filter) : super(const AsyncValue.loading()) {
    fetch();
  }

  final NotificationFilterType filter;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const PagedWithTotal();

      final data = await Api.get(GqlQuery.notifications, {
        'page': value.next,
        if (filter == NotificationFilterType.all) ...{
          'withCount': true,
          'resetCount': true,
        } else
          'filter': filter.vars,
      });

      int? unreadCount;
      if (filter.index < 1) {
        unreadCount = data['Viewer']['unreadNotificationCount'] ?? 0;
      }

      final items = <SiteNotification>[];
      for (final n in data['Page']['notifications']) {
        final item = SiteNotification.maybe(n);
        if (item != null) items.add(item);
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
        unreadCount,
      );
    });
  }
}

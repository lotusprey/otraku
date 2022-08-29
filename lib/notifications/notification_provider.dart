import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/notifications/notification_model.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';

final notificationFilterProvider = StateProvider.autoDispose(
  (ref) => NotificationFilterType.all,
);

final notificationsProvider = ChangeNotifierProvider.autoDispose(
  (ref) => NotificationsNotifier(ref.watch(notificationFilterProvider)),
);

class NotificationsNotifier extends ChangeNotifier {
  NotificationsNotifier(this.filter) {
    fetch();
  }

  final NotificationFilterType filter;

  int _unreadCount = 0;
  var _notifications = const AsyncValue<Pagination<SiteNotification>>.loading();

  int get unreadCount => _unreadCount;
  AsyncValue<Pagination<SiteNotification>> get notifications => _notifications;

  Future<void> fetch() async {
    _notifications = await AsyncValue.guard(() async {
      final value = _notifications.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.notifications, {
        'page': value.next,
        if (filter == NotificationFilterType.all) ...{
          'withCount': true,
          'resetCount': true,
        } else
          'filter': filter.vars,
      });

      _unreadCount = 0;
      if (filter.index < 1) {
        _unreadCount = data['Viewer']?['unreadNotificationCount'] ?? 0;
      }

      final items = <SiteNotification>[];
      for (final n in data['Page']['notifications']) {
        final item = SiteNotification.maybe(n);
        if (item != null) items.add(item);
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
    notifyListeners();
  }
}

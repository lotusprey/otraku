import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/notification/notifications_model.dart';

final notificationsFilterProvider = NotifierProvider.autoDispose<
    NotificationsFilterNotifier, NotificationFilter>(
  NotificationsFilterNotifier.new,
);

class NotificationsFilterNotifier
    extends AutoDisposeNotifier<NotificationFilter> {
  @override
  NotificationFilter build() => NotificationFilter.all;

  @override
  NotificationFilter get state => super.state;

  @override
  set state(NotificationFilter newState) => super.state = newState;
}

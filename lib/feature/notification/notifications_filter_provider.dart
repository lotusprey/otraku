import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/notification/notifications_filter_model.dart';

final notificationsFilterProvider =
    NotifierProvider.autoDispose<NotificationsFilterNotifier, NotificationsFilter>(
  NotificationsFilterNotifier.new,
);

class NotificationsFilterNotifier extends AutoDisposeNotifier<NotificationsFilter> {
  @override
  NotificationsFilter build() => NotificationsFilter.all;

  @override
  NotificationsFilter get state => super.state;

  @override
  set state(NotificationsFilter newState) => super.state = newState;
}

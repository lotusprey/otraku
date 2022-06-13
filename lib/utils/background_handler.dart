import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:otraku/notifications/notifications.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:workmanager/workmanager.dart';

final _notificationPlugin = FlutterLocalNotificationsPlugin();

class BackgroundHandler {
  BackgroundHandler._();

  static bool _didInit = false;
  static bool _didCheckLaunch = false;

  static Future<void> init() async {
    if (_didInit) return;
    _didInit = true;

    _notificationPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: IOSInitializationSettings(),
        macOS: MacOSInitializationSettings(),
      ),
      onSelectNotification: (payload) async => _handleNotification(payload),
    );

    await Workmanager().initialize(_fetch);

    if (Platform.isAndroid)
      Workmanager().registerPeriodicTask(
        '0',
        'notifications',
        constraints: Constraints(networkType: NetworkType.connected),
      );
  }

  // Should be called if the user logs out of an account.
  static void clearNotifications() => _notificationPlugin.cancelAll();

  static void checkIfLaunchedByNotification() {
    if (_didCheckLaunch) return;
    _didCheckLaunch = true;

    _notificationPlugin
        .getNotificationAppLaunchDetails()
        .then((launchDetails) => _handleNotification(launchDetails?.payload));
  }

  static void _handleNotification(String? link) {
    if (link == null) return;

    final uri = Uri.parse(link);
    if (uri.pathSegments.length < 2) return;

    final id = int.tryParse(uri.pathSegments[1]) ?? -1;
    if (id < 0) return;

    final context = RouteArg.navKey.currentContext;
    if (context == null) return;

    if (uri.pathSegments[0] == RouteArg.thread) {
      showPopUp(
        context,
        ConfirmationDialog(title: 'Sorry! Forum is not yet supported!'),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/${uri.pathSegments[0]}',
      arguments: RouteArg(id: id),
    );
  }
}

void _fetch() => Workmanager().executeTask((_, __) async {
      DartPluginRegistrant.ensureInitialized();

      // Initialise local settings.
      await Settings.init();
      if (Settings().selectedAccount == null) return true;

      // Log in.
      if (!Api.loggedIn()) {
        final ok = await Api.logIn(Settings().selectedAccount!);
        if (!ok) return true;
      }

      // Get new notifications.
      final data =
          await Api.request(GqlQuery.notifications, {'withCount': true});

      int count = data?['Viewer']?['unreadNotificationCount'] ?? 0;
      final ns = data?['Page']?['notifications'] ?? [];
      if (count > ns.length) count = ns.length;
      if (count == 0) return true;

      final last = Settings().lastNotificationId;
      Settings().lastNotificationId = ns[0]['id'];

      // Show notifications.
      for (int i = 0; i < count && ns[i]?['id'] != last; i++) {
        final notification = SiteNotification.maybe(ns[i]);
        if (notification == null) continue;

        switch (notification.type) {
          case NotificationType.FOLLOWING:
            _show(
              notification,
              'New Follow',
              '${RouteArg.user}/${notification.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_MESSAGE:
            _show(
              notification,
              'New Message',
              '${RouteArg.activity}/${notification.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_REPLY:
          case NotificationType.ACTIVITY_REPLY_SUBSCRIBED:
            _show(
              notification,
              'New Reply',
              '${RouteArg.activity}/${notification.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_MENTION:
            _show(
              notification,
              'New Mention',
              '${RouteArg.activity}/${notification.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_LIKE:
            _show(
              notification,
              'New Activity Like',
              '${RouteArg.activity}/${notification.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_REPLY_LIKE:
            _show(
              notification,
              'New Reply Like',
              '${RouteArg.activity}/${notification.bodyId}',
            );
            break;
          case NotificationType.THREAD_COMMENT_REPLY:
            _show(
              notification,
              'New Forum Reply',
              '${RouteArg.thread}/${notification.bodyId}',
            );
            break;
          case NotificationType.THREAD_COMMENT_MENTION:
            _show(
              notification,
              'New Forum Mention',
              '${RouteArg.thread}/${notification.bodyId}',
            );
            break;
          case NotificationType.THREAD_SUBSCRIBED:
            _show(
              notification,
              'New Forum Comment',
              '${RouteArg.thread}/${notification.bodyId}',
            );
            break;
          case NotificationType.THREAD_LIKE:
            _show(
              notification,
              'New Forum Like',
              '${RouteArg.thread}/${notification.bodyId}',
            );
            break;
          case NotificationType.THREAD_COMMENT_LIKE:
            _show(
              notification,
              'New Forum Comment Like',
              '${RouteArg.thread}/${notification.bodyId}',
            );
            break;
          case NotificationType.AIRING:
            _show(
              notification,
              'New Episode',
              '${RouteArg.media}/${notification.bodyId}',
            );
            break;
          case NotificationType.RELATED_MEDIA_ADDITION:
            _show(
              notification,
              'New Addition',
              '${RouteArg.media}/${notification.bodyId}',
            );
            break;
          case NotificationType.MEDIA_DATA_CHANGE:
            _show(
              notification,
              'Modified Media',
              '${RouteArg.media}/${notification.bodyId}',
            );
            break;
          case NotificationType.MEDIA_MERGE:
            _show(
              notification,
              'Merged Media',
              '${RouteArg.media}/${notification.bodyId}',
            );
            break;
          case NotificationType.MEDIA_DELETION:
            _show(notification, 'Deleted Media', '');
            break;
          default:
            break;
        }
      }

      return true;
    });

void _show(SiteNotification notification, String title, String payload) {
  final id = notification.type.name;
  final name = Convert.clarifyEnum(id)!;

  _notificationPlugin.show(
    notification.id,
    title,
    notification.texts.join(),
    NotificationDetails(
      android: AndroidNotificationDetails(
        id,
        name,
        channelDescription: name,
        color: const Color(0xFF45A0F2),
      ),
    ),
    payload: payload,
  );
}

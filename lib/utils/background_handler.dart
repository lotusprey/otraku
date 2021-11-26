import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:otraku/constants/notification_type.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/local_settings.dart';
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
  static void dispose() {
    _didInit = false;
    Workmanager().cancelAll();
  }

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
        ConfirmationDialog(
          title: 'Sorry! Forum is not yet supported!',
          mainAction: 'Ok',
        ),
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

void _fetch() => Workmanager().executeTask((_, input) async {
      // Initialise local settings.
      await LocalSettings.init();
      if (LocalSettings.onPrimaryAccount == null) return true;

      // Log in.
      if (!Client.loggedIn()) {
        final ok = await Client.logIn(LocalSettings.onPrimaryAccount!);
        if (!ok) return true;
      }

      // Get new notifications.
      final data =
          await Client.request(GqlQuery.notifications, {'withCount': true});
      if (data == null) return false;

      final int newCount = data['Viewer']?['unreadNotificationCount'] ?? 0;
      final int oldCount = LocalSettings().notificationCount;
      final count = newCount < oldCount ? newCount : newCount - oldCount;
      if (count < 1) return true;

      // Save new notification count.
      LocalSettings().notificationCount = newCount;

      // Show notifications.
      final ns = data['Page']['notifications'];
      for (int i = 0; i < count && i < ns.length; i++) {
        late NotificationModel model;
        try {
          model = NotificationModel(ns[i]);
        } catch (_) {
          continue;
        }

        switch (model.type) {
          case NotificationType.FOLLOWING:
            _show(
              model,
              'New Follow',
              '${RouteArg.user}/${model.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_MESSAGE:
            _show(
              model,
              'New Message',
              '${RouteArg.activity}/${model.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_REPLY:
          case NotificationType.ACTIVITY_REPLY_SUBSCRIBED:
            _show(
              model,
              'New Reply',
              '${RouteArg.activity}/${model.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_MENTION:
            _show(
              model,
              'New Mention',
              '${RouteArg.activity}/${model.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_LIKE:
            _show(
              model,
              'New Activity Like',
              '${RouteArg.activity}/${model.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_REPLY_LIKE:
            _show(
              model,
              'New Reply Like',
              '${RouteArg.activity}/${model.bodyId}',
            );
            break;
          case NotificationType.THREAD_COMMENT_REPLY:
            _show(
              model,
              'New Forum Reply',
              '${RouteArg.thread}/${model.bodyId}',
            );
            break;
          case NotificationType.THREAD_COMMENT_MENTION:
            _show(
              model,
              'New Forum Mention',
              '${RouteArg.thread}/${model.bodyId}',
            );
            break;
          case NotificationType.THREAD_SUBSCRIBED:
            _show(
              model,
              'New Forum Comment',
              '${RouteArg.thread}/${model.bodyId}',
            );
            break;
          case NotificationType.THREAD_LIKE:
            _show(
              model,
              'New Forum Like',
              '${RouteArg.thread}/${model.bodyId}',
            );
            break;
          case NotificationType.THREAD_COMMENT_LIKE:
            _show(
              model,
              'New Forum Comment Like',
              '${RouteArg.thread}/${model.bodyId}',
            );
            break;
          case NotificationType.AIRING:
            _show(
              model,
              'New Episode',
              '${RouteArg.media}/${model.bodyId}',
            );
            break;
          case NotificationType.RELATED_MEDIA_ADDITION:
            _show(
              model,
              'New Addition',
              '${RouteArg.media}/${model.bodyId}',
            );
            break;
          case NotificationType.MEDIA_DATA_CHANGE:
            _show(
              model,
              'Modified Media',
              '${RouteArg.media}/${model.bodyId}',
            );
            break;
          case NotificationType.MEDIA_MERGE:
            _show(
              model,
              'Merged Media',
              '${RouteArg.media}/${model.bodyId}',
            );
            break;
          case NotificationType.MEDIA_DELETION:
            _show(model, 'Deleted Media', '');
            break;
          default:
            break;
        }
      }

      return true;
    });

void _show(NotificationModel model, String title, String payload) {
  final id = describeEnum(model.type);
  final name = Convert.clarifyEnum(id)!;

  _notificationPlugin.show(
    model.id,
    title,
    model.texts.join(),
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

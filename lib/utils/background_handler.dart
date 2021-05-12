import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/pages/activity_page.dart';
import 'package:otraku/pages/home/user_page.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:workmanager/workmanager.dart';

final _notificationPlugin = FlutterLocalNotificationsPlugin();

class BackgroundHandler {
  BackgroundHandler._();

  static bool _didInit = false;
  static bool _didCheckLaunch = false;

  static void init(BuildContext ctx) {
    if (_didInit) return;
    _didInit = true;

    _notificationPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: IOSInitializationSettings(),
        macOS: MacOSInitializationSettings(),
      ),
      onSelectNotification: (payload) async =>
          _handleNotification(ctx, payload),
    );

    Workmanager().initialize(_fetch);

    if (Platform.isAndroid)
      Workmanager().registerPeriodicTask(
        '0',
        'notification',
        constraints: Constraints(networkType: NetworkType.connected),
      );
  }

  static void checkLaunchedByNotification(BuildContext ctx) {
    if (_didCheckLaunch) return;
    _didCheckLaunch = true;

    _notificationPlugin.getNotificationAppLaunchDetails().then(
        (launchDetails) => _handleNotification(ctx, launchDetails?.payload));
  }

  static void _handleNotification(BuildContext ctx, String? payload) {
    if (payload == null) return;

    final separator = payload.indexOf('/', 1);
    final route = payload.substring(0, separator);
    final id = int.tryParse(payload.substring(separator + 1)) ?? -1;
    if (id < 0) return;

    if (route == '/thread') {
      showPopUp(
        ctx,
        AlertDialog(
          shape:
              const RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
          backgroundColor: Theme.of(ctx).primaryColor,
          title: Text('Sorry! Forum is not yet supported!'),
          actions: [
            TextButton(child: Text('Ok'), onPressed: Navigator.of(ctx).pop),
          ],
        ),
      );
      return;
    }

    Get.toNamed(
      route,
      arguments: [id, null, null],
      parameters: {'id': id.toString()},
    );
  }
}

void _fetch() => Workmanager().executeTask((_, input) async {
      await GetStorage.init();

      // Log in
      if (Client.viewerId == null) {
        final ok = await Client.logIn();
        if (!ok) return true;
      }

      // Get the count of new notifications
      Map<String, dynamic>? data = await Client.request(
        _countQuery,
        null,
        popOnErr: false,
        silentErr: true,
      );
      if (data == null) return false;

      final int lastCount =
          Config.storage.read(Config.LAST_NOTIFICATION_COUNT) ?? 0;
      final int newCount = data['Viewer']['unreadNotificationCount'] ?? 0;
      final count = newCount - lastCount;
      if (count < 1) return true;

      // Get new notifications
      data = await Client.request(
        _notificationQuery,
        {'perPage': count},
        popOnErr: false,
        silentErr: true,
      );
      if (data == null) return false;

      // Save new notification count
      Config.storage.write(Config.LAST_NOTIFICATION_COUNT, newCount);

      // Show notifications
      for (final n in data['Page']['notifications']) {
        late NotificationModel model;
        try {
          model = NotificationModel(n);
        } catch (_) {
          continue;
        }

        switch (model.type) {
          case NotificationType.FOLLOWING:
            _show(model, 'New Follow', '${UserPage.ROUTE}/${model.bodyId}');
            break;
          case NotificationType.ACTIVITY_MESSAGE:
            _show(
                model, 'New Message', '${ActivityPage.ROUTE}/${model.bodyId}');
            break;
          case NotificationType.ACTIVITY_REPLY:
          case NotificationType.ACTIVITY_REPLY_SUBSCRIBED:
            _show(model, 'New Reply', '${ActivityPage.ROUTE}/${model.bodyId}');
            break;
          case NotificationType.ACTIVITY_MENTION:
            _show(
                model, 'New Mention', '${ActivityPage.ROUTE}/${model.bodyId}');
            break;
          case NotificationType.ACTIVITY_LIKE:
            _show(
              model,
              'New Activity Like',
              '${ActivityPage.ROUTE}/${model.bodyId}',
            );
            break;
          case NotificationType.ACTIVITY_REPLY_LIKE:
            _show(
              model,
              'New Reply Like',
              '${ActivityPage.ROUTE}/${model.bodyId}',
            );
            break;
          case NotificationType.THREAD_COMMENT_REPLY:
            _show(model, 'New Forum Reply', '/thread/${model.bodyId}');
            break;
          case NotificationType.THREAD_COMMENT_MENTION:
            _show(model, 'New Forum Mention', '/thread/${model.bodyId}');
            break;
          case NotificationType.THREAD_SUBSCRIBED:
            _show(model, 'New Forum Comment', '/thread/${model.bodyId}');
            break;
          case NotificationType.THREAD_LIKE:
            _show(model, 'New Forum Like', '/thread/${model.bodyId}');
            break;
          case NotificationType.THREAD_COMMENT_LIKE:
            _show(model, 'New Forum Comment Like', '/thread/${model.bodyId}');
            break;
          case NotificationType.AIRING:
            _show(model, 'New Episode', '${MediaPage.ROUTE}/${model.bodyId}');
            break;
          case NotificationType.RELATED_MEDIA_ADDITION:
            _show(model, 'New Addition', '${MediaPage.ROUTE}/${model.bodyId}');
            break;
          default:
            break;
        }
      }

      return true;
    });

void _show(NotificationModel model, String title, String payload) =>
    _notificationPlugin.show(
      model.id,
      title,
      model.texts.join(),
      _details,
      payload: payload,
    );

const _details = NotificationDetails(
  android: AndroidNotificationDetails(
    'NOTIFICATIONS',
    'Notifications',
    'All Notifications',
    color: Color(0xFF45A0F2),
  ),
);

const _countQuery = 'query Count {Viewer {unreadNotificationCount}}';

const _notificationQuery = r'''
  query Notifications($perPage: Int) {
    Page(perPage: $perPage) {
      notifications(resetNotificationCount: false) {
        ... on FollowingNotification {
          id
          type
          user {id name avatar {large}}
          createdAt
        }
        ... on ActivityMessageNotification {
          id
          type
          activityId
          user {id name avatar {large}}
          createdAt
        }
        ... on ActivityReplyNotification {
          id
          type
          activityId
          user {id name avatar {large}}
          createdAt
        }
        ... on ActivityReplySubscribedNotification {
          id
          type
          activityId
          user {id name avatar {large}}
          createdAt
        }
        ... on ThreadCommentReplyNotification {
          id
          type
          context
          commentId
          thread {title}
          user {id name avatar {large}}
          createdAt
        }
        ... on ActivityMentionNotification {
          id
          type
          activityId
          user {id name avatar {large}}
          createdAt
        }
        ... on ThreadCommentMentionNotification {
          id
          type
          commentId
          thread {title}
          user {id name avatar {large}}
          createdAt
        }
        ... on ThreadCommentSubscribedNotification {
          id
          type
          commentId
          thread {title}
          user {id name avatar {large}}
          createdAt
        }
        ... on ActivityLikeNotification {
          id
          type
          activityId
          user {id name avatar {large}}
          createdAt
        }
        ... on ActivityReplyLikeNotification {
          id
          type
          activityId
          user {id name avatar {large}}
          createdAt
        }
        ... on ThreadLikeNotification {
          id
          type
          thread {id title}
          user {id name avatar {large}}
          createdAt
        }
        ... on ThreadCommentLikeNotification {
          id
          type
          commentId
          thread {title}
          user {id name avatar {large}}
          createdAt
        }
        ... on AiringNotification {
          id
          type
          episode
          media {id type bannerImage title {userPreferred} coverImage {large}}
          createdAt
        }
        ... on RelatedMediaAdditionNotification {
          id
          type
          media {id type bannerImage title {userPreferred} coverImage {large}}
          createdAt
        }
      }
    }
  }
''';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:workmanager/workmanager.dart';

const _countQuery = r'''query Count {Viewer {unreadNotificationCount}}''';

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

final _notificationPlugin = FlutterLocalNotificationsPlugin();

void _fetch() => Workmanager().executeTask((_, input) async {
      await GetStorage.init();

      // Log in
      if (Client.viewerId == null) {
        final ok = await Client.logIn();
        if (!ok) return false;
      }

      // Get the count of new notifications
      Map<String, dynamic>? data = await Client.request(
        _countQuery,
        {},
        popOnErr: false,
        silentErr: true,
      );
      if (data == null) return false;

      int count = data['Viewer']['unreadNotificationCount'];
      count -= Config.storage.read(Config.LAST_NOTIFICATION_COUNT) ?? 0;
      if (count < 1) return true;

      _notificationPlugin.show(
        0,
        'title',
        'body',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'NOTIFICATIONS',
            'Notifications',
            'Notification channel',
          ),
        ),
        payload: 'count: $count',
      );

      // Get new notifications
      data = await Client.request(
        _notificationQuery,
        {'perPage': count},
        popOnErr: false,
        silentErr: true,
      );
      if (data == null) return false;

      final nl = <NotificationModel>[];
      for (final n in data['Page']['notifications'])
        try {
          nl.add(NotificationModel(n));
        } catch (_) {}

      // Send device notifications
      // _notificationPlugin.show(
      //   0,
      //   'title',
      //   'body',
      //   NotificationDetails(
      //     android: AndroidNotificationDetails(
      //       'NOTIFICATIONS',
      //       'Notifications',
      //       'Notification channel',
      //     ),
      //   ),
      //   payload: 'notification data',
      // );

      return true;
    });

class BackgroundHandler {
  BackgroundHandler._();

  static String? _notificationData;
  static String? get notificationData => _notificationData;

  static bool _didInit = false;

  static void init() {
    if (_didInit) return;

    _notificationPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher_foreground'),
        iOS: IOSInitializationSettings(),
        macOS: MacOSInitializationSettings(),
      ),
      onSelectNotification: (payload) async {
        debugPrint('notification payload: [$payload]');
        _notificationData = payload;
      },
    );

    Workmanager().initialize(_fetch, isInDebugMode: true);

    if (Platform.isAndroid)
      Workmanager().registerPeriodicTask(
        '0',
        'notification',
        constraints: Constraints(networkType: NetworkType.connected),
      );

    _didInit = true;
  }
}

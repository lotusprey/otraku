import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/notification/notifications_model.dart';
import 'package:otraku/util/graphql.dart';
import 'package:workmanager/workmanager.dart';

final _notificationPlugin = FlutterLocalNotificationsPlugin();

class BackgroundHandler {
  BackgroundHandler._();

  static Future<void> init(StreamController<String> notificationCtrl) async {
    _notificationPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        notificationCtrl.add(response.payload!);
      },
    );

    // Check if the app was launched by a notification.
    _notificationPlugin.getNotificationAppLaunchDetails().then(
      (launchDetails) {
        if (launchDetails?.notificationResponse?.payload == null) return;
        notificationCtrl.add(launchDetails!.notificationResponse!.payload!);
      },
    );

    await Workmanager().initialize(_fetch);

    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(
        '0',
        'notifications',
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  }

  /// Request for a permission to send notifications, if not already granted.
  static Future<bool> requestPermissionForNotifications() async {
    final android = _notificationPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    if (await android.areNotificationsEnabled() ?? true) return true;
    return await android.requestNotificationsPermission() ?? true;
  }

  /// Should be called, for example, when the user logs out of an account.
  static void clearNotifications() => _notificationPlugin.cancelAll();
}

@pragma('vm:entry-point')
void _fetch() => Workmanager().executeTask((_, __) async {
      final container = ProviderContainer();

      await container.read(persistenceProvider.notifier).init();
      final persistence = container.read(persistenceProvider);

      // No notifications are fetched in guest mode.
      if (persistence.accountGroup.accountIndex == null) return true;

      var appMeta = AppMeta(
        lastBackgroundJob: DateTime.now(),
        lastNotificationId: persistence.appMeta.lastNotificationId,
        lastAppVersion: persistence.appMeta.lastAppVersion,
      );
      container.read(persistenceProvider.notifier).setAppMeta(appMeta);

      final repository = container.read(repositoryProvider);
      Map<String, dynamic> data;
      try {
        data = await repository.request(
          GqlQuery.notifications,
          const {'withCount': true},
        );
      } catch (_) {
        return true;
      }

      int count = data['Viewer']?['unreadNotificationCount'] ?? 0;
      final ns = data['Page']?['notifications'] ?? [];
      if (count > ns.length) count = ns.length;
      if (count == 0) return true;

      final lastNotificationId = persistence.appMeta.lastNotificationId;

      appMeta = AppMeta(
        lastNotificationId: ns[0]?['id'] ?? -1,
        lastBackgroundJob: persistence.appMeta.lastBackgroundJob,
        lastAppVersion: persistence.appMeta.lastAppVersion,
      );
      container.read(persistenceProvider.notifier).setAppMeta(appMeta);

      for (int i = 0; i < count && ns[i]?['id'] != lastNotificationId; i++) {
        final notification = SiteNotification.maybe(
          ns[i],
          persistence.options.imageQuality,
        );

        if (notification == null) continue;

        (switch (notification.type) {
          NotificationType.following => _show(
              notification,
              'New Follow',
              Routes.user((notification as FollowNotification).userId),
            ),
          NotificationType.activityMention => _show(
              notification,
              'New Mention',
              Routes.activity(
                (notification as ActivityNotification).activityId,
              ),
            ),
          NotificationType.activityMessage => _show(
              notification,
              'New Message',
              Routes.activity(
                (notification as ActivityNotification).activityId,
              ),
            ),
          NotificationType.activityReply => _show(
              notification,
              'New Reply',
              Routes.activity(
                (notification as ActivityNotification).activityId,
              ),
            ),
          NotificationType.activityReplySubscribed => _show(
              notification,
              'New Reply To Subscribed Activity',
              Routes.activity(
                (notification as ActivityNotification).activityId,
              ),
            ),
          NotificationType.activityLike => _show(
              notification,
              'New Activity Like',
              Routes.activity(
                (notification as ActivityNotification).activityId,
              ),
            ),
          NotificationType.acrivityReplyLike => _show(
              notification,
              'New Reply Like',
              Routes.activity(
                (notification as ActivityNotification).activityId,
              ),
            ),
          NotificationType.threadLike => _show(
              notification,
              'New Forum Like',
              Routes.thread((notification as ThreadNotification).threadId),
            ),
          NotificationType.threadCommentReply => _show(
              notification,
              'New Forum Reply',
              Routes.comment(
                (notification as ThreadCommentNotification).commentId,
              ),
            ),
          NotificationType.threadCommentMention => _show(
              notification,
              'New Forum Mention',
              Routes.comment(
                (notification as ThreadCommentNotification).commentId,
              ),
            ),
          NotificationType.threadReplySubscribed => _show(
              notification,
              'New Forum Comment',
              Routes.comment(
                (notification as ThreadCommentNotification).commentId,
              ),
            ),
          NotificationType.threadCommentLike => _show(
              notification,
              'New Forum Comment Like',
              Routes.comment(
                (notification as ThreadCommentNotification).commentId,
              ),
            ),
          NotificationType.airing => _show(
              notification,
              'New Episode',
              Routes.media(
                (notification as MediaReleaseNotification).mediaId,
              ),
            ),
          NotificationType.relatedMediaAddition => _show(
              notification,
              'Added Media',
              Routes.media(
                (notification as MediaReleaseNotification).mediaId,
              ),
            ),
          NotificationType.mediaDataChange => _show(
              notification,
              'Modified Media',
              Routes.media(
                (notification as MediaChangeNotification).mediaId,
              ),
            ),
          NotificationType.mediaMerge => _show(
              notification,
              'Merged Media',
              Routes.media(
                (notification as MediaChangeNotification).mediaId,
              ),
            ),
          NotificationType.mediaDeletion => _show(
              notification,
              'Deleted Media',
              Routes.notifications,
            ),
        });
      }

      return true;
    });

() _show(SiteNotification notification, String title, String payload) {
  _notificationPlugin.show(
    notification.id,
    title,
    notification.texts.join(),
    NotificationDetails(
      android: AndroidNotificationDetails(
        notification.type.name,
        notification.type.label,
        channelDescription: notification.type.label,
      ),
    ),
    payload: payload,
  );
  return ();
}

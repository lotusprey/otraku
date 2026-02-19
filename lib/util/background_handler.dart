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
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        notificationCtrl.add(response.payload!);
      },
    );

    // Check if the app was launched by a notification.
    _notificationPlugin.getNotificationAppLaunchDetails().then((launchDetails) {
      if (launchDetails?.notificationResponse?.payload == null) return;
      notificationCtrl.add(launchDetails!.notificationResponse!.payload!);
    });

    await Workmanager().initialize(_fetch);

    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(
        '0',
        'notifications',
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  }

  /// Requests a notifications permission, if not already granted.
  static Future<void> requestPermissionForNotifications() async {
    if (Platform.isAndroid) {
      final platform = _notificationPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (platform == null) return;

      if (await platform.areNotificationsEnabled() ?? false) return;

      await platform.requestNotificationsPermission();
      return;
    }

    if (Platform.isIOS) {
      final platform = _notificationPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (platform == null) return;

      final permissions = await platform.checkPermissions();
      if (permissions?.isEnabled ?? false) return;

      await platform.requestPermissions(sound: true, badge: true);
      return;
    }
  }

  /// Clears device notifications.
  static void clearNotifications() => _notificationPlugin.cancelAll();
}

@pragma('vm:entry-point')
void _fetch() => Workmanager().executeTask((_, _) async {
  final container = ProviderContainer(retry: (retryCount, error) => null);

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
    data = await repository.request(GqlQuery.notifications, const {'withCount': true});
  } catch (_) {
    return true;
  }

  int count = data['Viewer']?['unreadNotificationCount'] ?? 0;
  final List<dynamic> notifications = data['Page']?['notifications'] ?? const [];

  if (count > notifications.length) count = notifications.length;
  if (count == 0) return true;

  final lastNotificationId = persistence.appMeta.lastNotificationId;

  appMeta = AppMeta(
    lastNotificationId: notifications[0]['id'] ?? -1,
    lastBackgroundJob: persistence.appMeta.lastBackgroundJob,
    lastAppVersion: persistence.appMeta.lastAppVersion,
  );
  container.read(persistenceProvider.notifier).setAppMeta(appMeta);

  for (int i = 0; i < count && notifications[i]['id'] != lastNotificationId; i++) {
    final notification = SiteNotification.maybe(notifications[i], persistence.options.imageQuality);

    if (notification == null) continue;

    (switch (notification.type) {
      .following => _show(
        notification,
        'New Follow',
        Routes.user((notification as FollowNotification).userId),
      ),
      .activityMention => _show(
        notification,
        'New Mention',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityMessage => _show(
        notification,
        'New Message',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityReply => _show(
        notification,
        'New Reply',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityReplySubscribed => _show(
        notification,
        'New Reply To Subscribed Activity',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityLike => _show(
        notification,
        'New Activity Like',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .acrivityReplyLike => _show(
        notification,
        'New Reply Like',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .threadLike => _show(
        notification,
        'New Forum Like',
        Routes.thread((notification as ThreadNotification).threadId),
      ),
      .threadCommentReply => _show(
        notification,
        'New Forum Reply',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .threadCommentMention => _show(
        notification,
        'New Forum Mention',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .threadReplySubscribed => _show(
        notification,
        'New Forum Comment',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .threadCommentLike => _show(
        notification,
        'New Forum Comment Like',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .airing => _show(
        notification,
        'New Episode',
        Routes.media((notification as MediaReleaseNotification).mediaId),
      ),
      .relatedMediaAddition => _show(
        notification,
        'Added Media',
        Routes.media((notification as MediaReleaseNotification).mediaId),
      ),
      .mediaDataChange => _show(
        notification,
        'Modified Media',
        Routes.media((notification as MediaChangeNotification).mediaId),
      ),
      .mediaMerge => _show(
        notification,
        'Merged Media',
        Routes.media((notification as MediaChangeNotification).mediaId),
      ),
      .mediaDeletion => _show(notification, 'Deleted Media', Routes.notifications),
    });
  }

  return true;
});

() _show(SiteNotification notification, String title, String payload) {
  _notificationPlugin.show(
    id: notification.id,
    title: title,
    body: notification.texts.join(),
    payload: payload,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        notification.type.name,
        notification.type.label,
        channelDescription: notification.type.label,
      ),
    ),
  );
  return ();
}

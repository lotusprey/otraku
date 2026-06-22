import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/localizations/gen_en.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/notification/notifications_model.dart';
import 'package:otraku/util/graphql.dart';
import 'package:workmanager/workmanager.dart';

final _notificationPlugin = FlutterLocalNotificationsPlugin();

class BackgroundWorker {
  BackgroundWorker._();

  static Future<void> init(StreamController<String> notificationCtrl) async {
    WidgetsFlutterBinding.ensureInitialized();

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
        inputData: {'languageCode': PlatformDispatcher.instance.locale.languageCode},
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
void _fetch() => Workmanager().executeTask((_, inputData) async {
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

  final l10n = _getLocalizations(inputData);
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
        l10n,
        notification,
        'New Follow',
        Routes.user((notification as FollowNotification).userId),
      ),
      .activityMention => _show(
        l10n,
        notification,
        'New Mention',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityMessage => _show(
        l10n,
        notification,
        'New Message',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityReply => _show(
        l10n,
        notification,
        'New Reply',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityReplySubscribed => _show(
        l10n,
        notification,
        'New Reply To Subscribed Activity',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .activityLike => _show(
        l10n,
        notification,
        'New Activity Like',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .acrivityReplyLike => _show(
        l10n,
        notification,
        'New Reply Like',
        Routes.activity((notification as ActivityNotification).activityId),
      ),
      .threadLike => _show(
        l10n,
        notification,
        'New Forum Like',
        Routes.thread((notification as ThreadNotification).threadId),
      ),
      .threadCommentReply => _show(
        l10n,
        notification,
        'New Forum Reply',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .threadCommentMention => _show(
        l10n,
        notification,
        'New Forum Mention',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .threadReplySubscribed => _show(
        l10n,
        notification,
        'New Forum Comment',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .threadCommentLike => _show(
        l10n,
        notification,
        'New Forum Comment Like',
        Routes.comment((notification as ThreadCommentNotification).commentId),
      ),
      .airing => _show(
        l10n,
        notification,
        'New Episode',
        Routes.media((notification as MediaReleaseNotification).mediaId),
      ),
      .relatedMediaAddition => _show(
        l10n,
        notification,
        'Added Media',
        Routes.media((notification as MediaReleaseNotification).mediaId),
      ),
      .mediaDataChange => _show(
        l10n,
        notification,
        'Modified Media',
        Routes.media((notification as MediaChangeNotification).mediaId),
      ),
      .mediaMerge => _show(
        l10n,
        notification,
        'Merged Media',
        Routes.media((notification as MediaChangeNotification).mediaId),
      ),
      .mediaDeletion => _show(l10n, notification, 'Deleted Media', Routes.notifications),
      .mediaSubmissionUpdate => _show(
        l10n,
        notification,
        'Media Submission Update',
        Routes.notifications,
      ),
      .characterSubmissionUpdate => _show(
        l10n,
        notification,
        'Character Submission Update',
        Routes.notifications,
      ),
      .staffSubmissionUpdate => _show(
        l10n,
        notification,
        'Staff Submission Update',
        Routes.notifications,
      ),
    });
  }

  return true;
});

AppLocalizations _getLocalizations(Map<String, dynamic>? inputData) {
  final languageCode = inputData?['languageCode'] ?? 'en';
  try {
    return lookupAppLocalizations(Locale(languageCode));
  } catch (_) {
    return AppLocalizationsEn();
  }
}

() _show(AppLocalizations l10n, SiteNotification notification, String title, String payload) {
  _notificationPlugin.show(
    id: notification.id,
    title: title,
    body: notification.texts.join(),
    payload: payload,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        notification.type.name,
        notification.type.localize(l10n),
        channelDescription: notification.type.localize(l10n),
      ),
    ),
  );
  return ();
}

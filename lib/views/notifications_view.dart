import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/routing/navigation.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/notifications_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifications = Get.find<NotificationsController>();
    return Scaffold(
      appBar: ShadowAppBar(
        title: 'Notifications',
        actions: [
          AppBarIcon(
            tooltip: 'Filter',
            icon: Ionicons.funnel_outline,
            onTap: () => Sheet.show(
              ctx: context,
              sheet: OptionSheet(
                title: 'Category',
                options: ['All', 'Activities', 'Forum', 'Media', 'Follows'],
                index: notifications.filter,
                onTap: (val) => notifications.filter = val,
              ),
              isScrollControlled: true,
            ),
          ),
        ],
      ),
      body: GetBuilder<NotificationsController>(builder: (notifications) {
        final entries = notifications.entries;
        return ListView.builder(
          padding: Config.PADDING,
          physics: Config.PHYSICS,
          controller: notifications.scrollCtrl,
          itemBuilder: (_, index) => _NotificationWidget(
            entries[index],
            index < notifications.unreadCount,
          ),
          itemCount: entries.length,
          itemExtent: 100,
        );
      }),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  final NotificationModel notification;
  final bool unread;

  _NotificationWidget(this.notification, this.unread);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            if (notification.imageUrl != null && notification.headId != null)
              GestureDetector(
                onTap: () => ExploreIndexer.openPage(
                  id: notification.headId!,
                  imageUrl: notification.imageUrl,
                  explorable: notification.explorable ?? Explorable.user,
                ),
                onLongPress: () {
                  if (notification.explorable == Explorable.anime ||
                      notification.explorable == Explorable.manga)
                    ExploreIndexer.openEditPage(notification.headId!);
                },
                child: ClipRRect(
                  child: FadeImage(notification.imageUrl!, width: 70),
                  borderRadius: BorderRadius.horizontal(left: Config.RADIUS),
                ),
              ),
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  switch (notification.type) {
                    case NotificationType.ACTIVITY_LIKE:
                    case NotificationType.ACTIVITY_MENTION:
                    case NotificationType.ACTIVITY_MESSAGE:
                    case NotificationType.ACTIVITY_REPLY:
                    case NotificationType.ACTIVITY_REPLY_LIKE:
                    case NotificationType.ACTIVITY_REPLY_SUBSCRIBED:
                      Navigation.it.push(
                        Navigation.activityRoute,
                        args: [notification.bodyId, null],
                      );
                      return;
                    case NotificationType.FOLLOWING:
                      ExploreIndexer.openPage(
                        id: notification.headId!,
                        imageUrl: notification.imageUrl,
                        explorable: Explorable.user,
                      );
                      return;
                    case NotificationType.AIRING:
                    case NotificationType.RELATED_MEDIA_ADDITION:
                      ExploreIndexer.openPage(
                        id: notification.bodyId!,
                        imageUrl: notification.imageUrl,
                        explorable: notification.explorable!,
                      );
                      return;
                    case NotificationType.MEDIA_DATA_CHANGE:
                    case NotificationType.MEDIA_MERGE:
                    case NotificationType.MEDIA_DELETION:
                      showPopUp(context, _NotificationDialog(notification));
                      return;
                    default:
                      Toast.show(context, 'Forum is not supported yet');
                      return;
                  }
                },
                onLongPress: () {
                  if (notification.explorable == Explorable.anime ||
                      notification.explorable == Explorable.manga)
                    ExploreIndexer.openEditPage(notification.headId!);
                },
                child: Padding(
                  padding: Config.PADDING,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        overflow: TextOverflow.fade,
                        text: TextSpan(
                          children: [
                            for (int i = 0; i < notification.texts.length; i++)
                              TextSpan(
                                text: notification.texts[i],
                                style: (i % 2 == 0) ==
                                        notification.markTextOnEvenIndex
                                    ? Theme.of(context).textTheme.bodyText1
                                    : Theme.of(context).textTheme.bodyText2,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        notification.timestamp,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (unread)
              Container(
                width: 10,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.horizontal(right: Config.RADIUS),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDialog extends StatelessWidget {
  final NotificationModel model;
  const _NotificationDialog(this.model);

  @override
  Widget build(BuildContext context) {
    final title = RichText(
      overflow: TextOverflow.fade,
      text: TextSpan(
        children: [
          for (int i = 0; i < model.texts.length; i++)
            TextSpan(
              text: model.texts[i],
              style: (i % 2 == 0) == model.markTextOnEvenIndex
                  ? Theme.of(context).textTheme.bodyText1
                  : Theme.of(context).textTheme.bodyText2,
            ),
        ],
      ),
    );

    return DialogBox(
      Column(
        children: [
          if (model.imageUrl == null)
            title
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FadeImage(model.imageUrl!),
                const SizedBox(width: 5),
                title,
              ],
            ),
          if (model.details != null) HtmlContent(model.details!),
        ],
      ),
    );
  }
}

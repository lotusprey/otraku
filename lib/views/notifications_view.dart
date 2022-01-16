import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/notifications_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/notification_type.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (ctrl) => Scaffold(
        appBar: ShadowAppBar(
          title: 'Notifications',
          actions: [
            AppBarIcon(
              tooltip: 'Filter',
              icon: Ionicons.funnel_outline,
              onTap: () => DragSheet.show(
                context,
                OptionDragSheet(
                  options: const [
                    'All',
                    'Airing',
                    'Activity',
                    'Forum',
                    'Follows',
                    'Media',
                  ],
                  index: ctrl.filter,
                  onTap: (val) => ctrl.filter = val,
                ),
              ),
            ),
          ],
        ),
        body: GetBuilder<NotificationsController>(
          id: NotificationsController.ID_LIST,
          builder: (ctrl) {
            final entries = ctrl.entries;
            return ListView.builder(
              padding: Consts.PADDING,
              physics: Consts.PHYSICS,
              controller: ctrl.scrollCtrl,
              itemBuilder: (_, index) => _NotificationWidget(
                entries[index],
                index < ctrl.unreadCount,
              ),
              itemCount: entries.length,
              itemExtent: 100,
            );
          },
        ),
      ),
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
          borderRadius: Consts.BORDER_RADIUS,
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            if (notification.imageUrl != null && notification.headId != null)
              GestureDetector(
                onTap: () => ExploreIndexer.openView(
                  ctx: context,
                  id: notification.headId!,
                  imageUrl: notification.imageUrl,
                  explorable: notification.explorable ?? Explorable.user,
                ),
                onLongPress: () {
                  if (notification.explorable == Explorable.anime ||
                      notification.explorable == Explorable.manga)
                    ExploreIndexer.openEditView(notification.headId!, context);
                },
                child: ClipRRect(
                  child: FadeImage(notification.imageUrl!, width: 70),
                  borderRadius: BorderRadius.horizontal(left: Consts.RADIUS),
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
                      Navigator.pushNamed(
                        context,
                        RouteArg.activity,
                        arguments: RouteArg(id: notification.bodyId),
                      );
                      return;
                    case NotificationType.FOLLOWING:
                      ExploreIndexer.openView(
                        ctx: context,
                        id: notification.headId!,
                        imageUrl: notification.imageUrl,
                        explorable: Explorable.user,
                      );
                      return;
                    case NotificationType.AIRING:
                    case NotificationType.RELATED_MEDIA_ADDITION:
                      ExploreIndexer.openView(
                        ctx: context,
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
                    ExploreIndexer.openEditView(notification.headId!, context);
                },
                child: Padding(
                  padding: Consts.PADDING,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        maxLines: 3,
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
                  borderRadius: BorderRadius.horizontal(right: Consts.RADIUS),
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

    final coverWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.35
        : 150.0;
    final coverHeight = coverWidth / 0.7;

    return DialogBox(
      Padding(
        padding: Consts.PADDING,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (model.imageUrl == null)
              title
            else
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: Consts.BORDER_RADIUS,
                      child: FadeImage(
                        model.imageUrl!,
                        width: coverWidth,
                        height: coverHeight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(child: title),
                  ],
                ),
              ),
            if (model.details != null) ...[
              const SizedBox(height: 10),
              HtmlContent(model.details!),
            ],
          ],
        ),
      ),
    );
  }
}

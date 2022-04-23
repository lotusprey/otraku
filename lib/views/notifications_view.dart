import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/notifications_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/notification_type.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/providers/notifications.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/views/edit_view.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView();

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShadowAppBar(
        title: 'Notifications',
        actions: [
          AppBarIcon(
            tooltip: 'Filter',
            icon: Ionicons.funnel_outline,
            onTap: () {
              showSheet(
                context,
                Consumer(
                  builder: (context, ref, _) {
                    final notifier = ref.read(
                      notificationFilterProvider.notifier,
                    );

                    return DynamicGradientDragSheet(
                      itemCount: 6,
                      onTap: (i) => notifier.state =
                          NotificationFilterType.values.elementAt(i),
                      itemBuilder: (_, i) => Text(
                        NotificationsController.FILTERS[i],
                        style: i != notifier.state.index
                            ? Theme.of(context).textTheme.headline1
                            : Theme.of(context).textTheme.headline1?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final notifier = ref.watch(notificationsProvider.notifier);

          final content = CustomScrollView(
            controller: _ctrl,
            slivers: [
              SliverRefreshControl(
                onRefresh: onRefresh,
                canRefresh: canRefresh,
              ),
            ],
          );

          final list = ListView.builder(
            padding: Consts.PADDING,
            controller: _ctrl,
            itemBuilder: (_, index) => _NotificationWidget(
              notifier.notifications[index],
              index < notifier.unreadCount,
            ),
            itemCount: notifier.notifications.length,
            itemExtent: 100,
          );

          return ref
              .watch(notificationsProvider.select((s) => s.dataState))
              .maybeWhen(
                data: (_) {
                  final notifier = ref.watch(notificationsProvider.notifier);
                },
                orElse: () {},
              );
        },
      ),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  _NotificationWidget(this.notification, this.unread);

  final NotificationModel notification;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: Consts.BORDER_RAD_MIN,
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
                    showSheet(context, EditView(notification.headId!));
                },
                child: ClipRRect(
                  child: FadeImage(notification.imageUrl!, width: 70),
                  borderRadius: BorderRadius.horizontal(
                    left: Consts.RADIUS_MIN,
                  ),
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
                      showPopUp(
                        context,
                        const ConfirmationDialog(
                          title: 'Forum is not yet supported',
                        ),
                      );
                      return;
                  }
                },
                onLongPress: () {
                  if (notification.explorable == Explorable.anime ||
                      notification.explorable == Explorable.manga)
                    showSheet(context, EditView(notification.headId!));
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
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius:
                      BorderRadius.horizontal(right: Consts.RADIUS_MIN),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDialog extends StatelessWidget {
  _NotificationDialog(this.model);

  final NotificationModel model;

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
        ? MediaQuery.of(context).size.width * 0.30
        : 100.0;

    return DialogBox(
      Padding(
        padding: Consts.PADDING,
        child: Row(
          children: [
            if (model.imageUrl != null) ...[
              ClipRRect(
                borderRadius: Consts.BORDER_RAD_MIN,
                child: FadeImage(
                  model.imageUrl!,
                  width: coverWidth,
                  height: coverWidth * Consts.COVER_HW_RATIO,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  title,
                  if (model.details != null) ...[
                    const SizedBox(height: 10),
                    HtmlContent(model.details!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/notifications/notifications.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView();

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  late final PaginationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PaginationController(
      loadMore: () => ref.read(notificationsProvider).fetch(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      topBar: TopBar(
        items: [
          Expanded(
            child: Consumer(
              builder: (context, ref, _) => Text(
                '${ref.watch(notificationFilterProvider).text} Notifications',
                style: Theme.of(context).textTheme.headline1,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
      floatingBar: FloatingBar(
        scrollCtrl: _ctrl,
        child: ActionButton(
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

                  final tiles = <Widget>[];
                  for (int i = 0; i < NotificationFilterType.values.length; i++)
                    tiles.add(Text(
                      NotificationFilterType.values.elementAt(i).text,
                      style: i != notifier.state.index
                          ? Theme.of(context).textTheme.headline1
                          : Theme.of(context).textTheme.headline1?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ));

                  return DynamicGradientDragSheet(
                    children: tiles,
                    onTap: (i) => notifier.state =
                        NotificationFilterType.values.elementAt(i),
                  );
                },
              ),
            );
          },
        ),
      ),
      builder: (context, topOffset, bottomOffset) => Consumer(
        child: SliverRefreshControl(
          onRefresh: () {
            ref.invalidate(notificationsProvider);
            return Future.value();
          },
        ),
        builder: (context, ref, refreshControl) {
          ref.listen<NotificationsNotifier>(
            notificationsProvider,
            (_, s) => s.notifications.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load notifications',
                  content: error.toString(),
                ),
              ),
            ),
          );

          const empty = Center(child: Text('No notifications'));

          final notifier = ref.watch(notificationsProvider);
          return notifier.notifications.maybeWhen(
            orElse: () => empty,
            loading: () => const Center(child: Loader()),
            data: (data) {
              if (data.items.isEmpty) return empty;

              return CustomScrollView(
                physics: Consts.physics,
                controller: _ctrl,
                slivers: [
                  refreshControl!,
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _NotificationWidget(
                          data.items[i],
                          i < notifier.unreadCount,
                        ),
                        childCount: data.items.length,
                      ),
                    ),
                  ),
                  SliverFooter(loading: data.hasNext),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  _NotificationWidget(this.notification, this.unread);

  final SiteNotification notification;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: Consts.borderRadiusMin,
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
                      left: Consts.radiusMin,
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
                    padding: Consts.padding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RichText(
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                          text: TextSpan(
                            children: [
                              for (int i = 0;
                                  i < notification.texts.length;
                                  i++)
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
                    borderRadius: const BorderRadius.horizontal(
                      right: Consts.radiusMin,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDialog extends StatelessWidget {
  _NotificationDialog(this.item);

  final SiteNotification item;

  @override
  Widget build(BuildContext context) {
    final title = RichText(
      overflow: TextOverflow.fade,
      text: TextSpan(
        children: [
          for (int i = 0; i < item.texts.length; i++)
            TextSpan(
              text: item.texts[i],
              style: (i % 2 == 0) == item.markTextOnEvenIndex
                  ? Theme.of(context).textTheme.bodyText1
                  : Theme.of(context).textTheme.bodyText2,
            ),
        ],
      ),
    );

    final imageWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.30
        : 100.0;

    return DialogBox(
      Padding(
        padding: Consts.padding,
        child: Row(
          children: [
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: FadeImage(
                  item.imageUrl!,
                  width: imageWidth,
                  height: imageWidth * Consts.coverHtoWRatio,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  title,
                  if (item.details != null) ...[
                    const SizedBox(height: 10),
                    HtmlContent(item.details!),
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

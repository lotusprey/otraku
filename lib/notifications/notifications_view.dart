import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/notifications/notification_model.dart';
import 'package:otraku/notifications/notification_provider.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

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
    BackgroundHandler.clearNotifications();
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
        children: [
          ActionButton(
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
                    for (int i = 0;
                        i < NotificationFilterType.values.length;
                        i++) {
                      tiles.add(Text(
                        NotificationFilterType.values.elementAt(i).text,
                        style: i != notifier.state.index
                            ? Theme.of(context).textTheme.headline1
                            : Theme.of(context).textTheme.headline1?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ));
                    }

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
        ],
      ),
      child: Consumer(
        child: SliverRefreshControl(
          onRefresh: () => ref.invalidate(notificationsProvider),
        ),
        builder: (context, ref, refreshControl) {
          ref.listen<NotificationsNotifier>(
            notificationsProvider,
            (_, s) => s.notifications.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load notifications',
                  content: error.toString(),
                ),
              ),
            ),
          );

          final notifier = ref.watch(notificationsProvider);
          return notifier.notifications.when(
            loading: () => const Center(child: Loader()),
            error: (_, __) =>
                const Center(child: Text('Failed to load notifications')),
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(child: Text('No notifications'));
              }

              return ConstrainedView(
                child: CustomScrollView(
                  physics: Consts.physics,
                  controller: _ctrl,
                  slivers: [
                    refreshControl!,
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _NotificationItem(
                            data.items[i],
                            i < notifier.unreadCount,
                          ),
                          childCount: data.items.length,
                        ),
                      ),
                    ),
                    SliverFooter(loading: data.hasNext),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem(this.item, this.unread);

  final SiteNotification item;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 90,
          child: Card(
            child: Row(
              children: [
                if (item.imageUrl != null && item.headId != null)
                  GestureDetector(
                    onTap: () => LinkTile.openView(
                      context: context,
                      id: item.headId!,
                      imageUrl: item.imageUrl,
                      discoverType: item.discoverType ?? DiscoverType.user,
                    ),
                    onLongPress: () {
                      if (item.discoverType == DiscoverType.anime ||
                          item.discoverType == DiscoverType.manga) {
                        showSheet(context, EditView(EditTag(item.headId!)));
                      }
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Consts.radiusMin,
                      ),
                      child: FadeImage(item.imageUrl!, width: 70),
                    ),
                  ),
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      switch (item.type) {
                        case NotificationType.ACTIVITY_LIKE:
                        case NotificationType.ACTIVITY_MENTION:
                        case NotificationType.ACTIVITY_MESSAGE:
                        case NotificationType.ACTIVITY_REPLY:
                        case NotificationType.ACTIVITY_REPLY_LIKE:
                        case NotificationType.ACTIVITY_REPLY_SUBSCRIBED:
                          Navigator.pushNamed(
                            context,
                            RouteArg.activity,
                            arguments: RouteArg(id: item.bodyId),
                          );
                          return;
                        case NotificationType.FOLLOWING:
                          LinkTile.openView(
                            context: context,
                            id: item.headId!,
                            imageUrl: item.imageUrl,
                            discoverType: DiscoverType.user,
                          );
                          return;
                        case NotificationType.AIRING:
                        case NotificationType.RELATED_MEDIA_ADDITION:
                          LinkTile.openView(
                            context: context,
                            id: item.bodyId!,
                            imageUrl: item.imageUrl,
                            discoverType: item.discoverType!,
                          );
                          return;
                        case NotificationType.MEDIA_DATA_CHANGE:
                        case NotificationType.MEDIA_MERGE:
                        case NotificationType.MEDIA_DELETION:
                          showPopUp(context, _NotificationDialog(item));
                          return;
                        case NotificationType.THREAD_LIKE:
                        case NotificationType.THREAD_SUBSCRIBED:
                        case NotificationType.THREAD_COMMENT_LIKE:
                        case NotificationType.THREAD_COMMENT_REPLY:
                        case NotificationType.THREAD_COMMENT_MENTION:
                          showPopUp(
                            context,
                            ConfirmationDialog(
                              title: 'Forum is not yet supported',
                              content: 'Open in browser?',
                              mainAction: 'Open',
                              secondaryAction: 'Cancel',
                              onConfirm: () {
                                if (item.details == null) {
                                  Toast.show(context, 'Invalid Link');
                                  return;
                                }
                                Toast.launch(context, item.details!);
                              },
                            ),
                          );
                          return;
                        default:
                          showPopUp(
                            context,
                            ConfirmationDialog(
                              title: 'Unknown action',
                              content: item.type.name,
                            ),
                          );
                          return;
                      }
                    },
                    onLongPress: () {
                      if (item.discoverType == DiscoverType.anime ||
                          item.discoverType == DiscoverType.manga) {
                        showSheet(context, EditView(EditTag(item.headId!)));
                      }
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
                                for (int i = 0; i < item.texts.length; i++)
                                  TextSpan(
                                    text: item.texts[i],
                                    style: (i % 2 == 0) ==
                                            item.markTextOnEvenIndex
                                        ? Theme.of(context).textTheme.bodyText1
                                        : Theme.of(context).textTheme.bodyText2,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            item.timestamp,
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
      ),
    );
  }
}

class _NotificationDialog extends StatelessWidget {
  const _NotificationDialog(this.item);

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

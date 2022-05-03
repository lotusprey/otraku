import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/notification_type.dart';
import 'package:otraku/providers/notifications.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/edit_view.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/header_layout.dart';
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
      reload: ref.read(notificationsProvider).fetch,
      loadMore: ref.read(notificationsProvider).fetchNext,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NotificationsNotifier>(
      notificationsProvider,
      (_, notifier) {
        if (notifier.pages.hasError)
          showPopUp(
            context,
            ConfirmationDialog(
              title: 'An error occured',
              content: notifier.pages.error.toString(),
            ),
          );
      },
    );

    final loader = const SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Loader(),
        ),
      ),
    );

    return Scaffold(
      body: HeaderLayout(
        canPop: true,
        topItems: [
          Expanded(
            child: Text(''),
          ),
        ],
        builder: (context, offsetTop) {
          final refreshIndicator = SliverRefreshControl(
            offsetTop: offsetTop,
            canRefresh: () => true,
            onRefresh: _ctrl.refresh,
          );

          return Consumer(
            builder: (context, ref, _) {
              final notifier = ref.watch(notificationsProvider);

              if (notifier.pages.value?.items.isEmpty ?? true) {
                if (notifier.pages.isLoading)
                  return const Center(child: Loader());

                return const Center(child: Text('No notifications'));
              }
              final data = notifier.pages.value!;

              return CustomScrollView(
                physics: Consts.PHYSICS,
                controller: _ctrl.scrollCtrl,
                slivers: [
                  refreshIndicator,
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  if (data.hasNext) loader,
                ],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: Settings().leftHanded
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingListener(
        scrollCtrl: _ctrl.scrollCtrl,
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

                  return DynamicGradientDragSheet(
                    itemCount: 6,
                    onTap: (i) => notifier.state =
                        NotificationFilterType.values.elementAt(i),
                    itemBuilder: (_, i) => Text(
                      notificationFilterNames[i],
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
      ),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  _NotificationWidget(this.notification, this.unread);

  final NotificationItem notification;
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
                      right: Consts.RADIUS_MIN,
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

  final NotificationItem item;

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
        padding: Consts.PADDING,
        child: Row(
          children: [
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: Consts.BORDER_RAD_MIN,
                child: FadeImage(
                  item.imageUrl!,
                  width: imageWidth,
                  height: imageWidth * Consts.COVER_HW_RATIO,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/notification/notification_model.dart';
import 'package:otraku/modules/notification/notification_provider.dart';
import 'package:otraku/common/utils/background_handler.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/modules/edit/edit_view.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';
import 'package:otraku/common/widgets/paged_view.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView();

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  late final _ctrl = PagedController(
    loadMore: () => ref.read(notificationsProvider.notifier).fetch(),
  );

  @override
  void initState() {
    super.initState();
    BackgroundHandler.clearNotifications();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(
      notificationsProvider.select((s) => s.valueOrNull?.total ?? 0),
    );

    return PageScaffold(
      child: TabScaffold(
        topBar: TopBar(
          trailing: [
            Expanded(
              child: Text(
                '${ref.watch(notificationFilterProvider).text} Notifications',
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
              onTap: _showFilterSheet,
            ),
          ],
        ),
        child: PagedView<SiteNotification>(
          provider: notificationsProvider,
          onData: (data) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _NotificationItem(data.items[i], i < unreadCount),
              childCount: data.items.length,
            ),
          ),
          scrollCtrl: _ctrl,
          onRefresh: () => ref.invalidate(notificationsProvider),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showSheet(
      context,
      Consumer(
        builder: (context, ref, _) {
          final index =
              ref.read(notificationFilterProvider.notifier).state.index;

          return GradientSheet([
            for (int i = 0; i < NotificationFilterType.values.length; i++)
              GradientSheetButton(
                text: NotificationFilterType.values.elementAt(i).text,
                selected: index == i,
                onTap: () => ref
                    .read(notificationFilterProvider.notifier)
                    .state = NotificationFilterType.values.elementAt(i),
              ),
          ]);
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
                    onTap: () => context.push(switch (item.discoverType) {
                      DiscoverType.Anime || DiscoverType.Manga => Routes.media(
                          item.headId!,
                          item.imageUrl,
                        ),
                      _ => Routes.user(item.headId!, item.imageUrl),
                    }),
                    onLongPress: () {
                      if (item.discoverType == DiscoverType.Anime ||
                          item.discoverType == DiscoverType.Manga) {
                        showSheet(
                          context,
                          EditView((id: item.headId!, setComplete: false)),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Consts.radiusMin,
                      ),
                      child: CachedImage(item.imageUrl!, width: 70),
                    ),
                  ),
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => switch (item.type) {
                      NotificationType.ACTIVITY_LIKE ||
                      NotificationType.ACTIVITY_MENTION ||
                      NotificationType.ACTIVITY_MESSAGE ||
                      NotificationType.ACTIVITY_REPLY ||
                      NotificationType.ACTIVITY_REPLY_LIKE ||
                      NotificationType.ACTIVITY_REPLY_SUBSCRIBED =>
                        context.push(Routes.activity(item.bodyId!)),
                      NotificationType.FOLLOWING =>
                        context.push(Routes.user(item.headId!, item.imageUrl)),
                      NotificationType.AIRING ||
                      NotificationType.RELATED_MEDIA_ADDITION =>
                        context.push(Routes.media(item.headId!, item.imageUrl)),
                      NotificationType.MEDIA_DATA_CHANGE ||
                      NotificationType.MEDIA_MERGE ||
                      NotificationType.MEDIA_DELETION =>
                        showPopUp(context, _NotificationDialog(item)),
                      NotificationType.THREAD_LIKE ||
                      NotificationType.THREAD_SUBSCRIBED ||
                      NotificationType.THREAD_COMMENT_LIKE ||
                      NotificationType.THREAD_COMMENT_REPLY ||
                      NotificationType.THREAD_COMMENT_MENTION =>
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
                        ),
                    },
                    onLongPress: () {
                      if (item.discoverType == DiscoverType.Anime ||
                          item.discoverType == DiscoverType.Manga) {
                        showSheet(
                          context,
                          EditView((id: item.headId!, setComplete: false)),
                        );
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
                                        ? Theme.of(context).textTheme.bodyLarge
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            item.createdAt,
                            style: Theme.of(context).textTheme.labelSmall,
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
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyMedium,
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
                child: CachedImage(
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

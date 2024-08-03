import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scaffold_extension.dart';
import 'package:otraku/feature/notification/notifications_filter_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/notification/notifications_filter_provider.dart';
import 'package:otraku/feature/notification/notifications_model.dart';
import 'package:otraku/feature/notification/notifications_provider.dart';
import 'package:otraku/util/background_handler.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/paged_view.dart';

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

    return ScaffoldExtension.expanded(
      context: context,
      topBar: TopBar(
        trailing: [
          Expanded(
            child: Text(
              '${ref.watch(notificationsFilterProvider).label} Notifications',
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      floatingActionConfig: (
        scrollCtrl: _ctrl,
        actions: [
          FloatingActionButton(
            tooltip: 'Filter',
            onPressed: _showFilterSheet,
            child: const Icon(Ionicons.funnel_outline),
          ),
        ],
      ),
      child: PagedView<SiteNotification>(
        scrollCtrl: _ctrl,
        onRefresh: (invalidate) => invalidate(notificationsProvider),
        provider: notificationsProvider,
        onData: (data) => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _NotificationItem(data.items[i], i < unreadCount),
            childCount: data.items.length,
          ),
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
              ref.read(notificationsFilterProvider.notifier).state.index;

          return SimpleSheet.list([
            for (int i = 0; i < NotificationsFilter.values.length; i++)
              ListTile(
                title: Text(NotificationsFilter.values.elementAt(i).label),
                selected: index == i,
                onTap: () {
                  ref.read(notificationsFilterProvider.notifier).state =
                      NotificationsFilter.values.elementAt(i);
                  Navigator.pop(context);
                },
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
                      DiscoverType.anime || DiscoverType.manga => Routes.media(
                          item.headId!,
                          item.imageUrl,
                        ),
                      _ => Routes.user(item.headId!, item.imageUrl),
                    }),
                    onLongPress: () {
                      if (item.discoverType == DiscoverType.anime ||
                          item.discoverType == DiscoverType.manga) {
                        showSheet(
                          context,
                          EditView((id: item.headId!, setComplete: false)),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Theming.radiusSmall,
                      ),
                      child: CachedImage(item.imageUrl!, width: 70),
                    ),
                  ),
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => switch (item.type) {
                      NotificationType.activityLike ||
                      NotificationType.activityMention ||
                      NotificationType.activityMessage ||
                      NotificationType.activityReply ||
                      NotificationType.acrivityReplyLike ||
                      NotificationType.activityReplySubscribed =>
                        context.push(Routes.activity(item.bodyId!)),
                      NotificationType.following =>
                        context.push(Routes.user(item.headId!, item.imageUrl)),
                      NotificationType.airing ||
                      NotificationType.relatedMediaAddition =>
                        context.push(Routes.media(item.headId!, item.imageUrl)),
                      NotificationType.mediaDataChange ||
                      NotificationType.mediaMerge ||
                      NotificationType.mediaDeletion =>
                        showDialog(
                          context: context,
                          builder: (context) => _NotificationDialog(item),
                        ),
                      NotificationType.threadLike ||
                      NotificationType.threadReplySubscribed ||
                      NotificationType.threadCommentLike ||
                      NotificationType.threadCommentReply ||
                      NotificationType.threadCommentMention =>
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            title: 'Forum is not yet supported',
                            content: 'Open in browser?',
                            mainAction: 'Open',
                            secondaryAction: 'Cancel',
                            onConfirm: () {
                              if (item.details == null) {
                                SnackBarExtension.show(context, 'Invalid Link');
                                return;
                              }
                              SnackBarExtension.launch(context, item.details!);
                            },
                          ),
                        ),
                    },
                    onLongPress: () {
                      if (item.discoverType == DiscoverType.anime ||
                          item.discoverType == DiscoverType.manga) {
                        showSheet(
                          context,
                          EditView((id: item.headId!, setComplete: false)),
                        );
                      }
                    },
                    child: Padding(
                      padding: Theming.paddingAll,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: Text.rich(
                              overflow: TextOverflow.fade,
                              TextSpan(
                                children: [
                                  for (int i = 0; i < item.texts.length; i++)
                                    TextSpan(
                                      text: item.texts[i],
                                      style: (i % 2 == 0)
                                          ? Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                    ),
                                ],
                              ),
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
                    width: Theming.offset,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.horizontal(
                        right: Theming.radiusSmall,
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
    final title = Text.rich(
      overflow: TextOverflow.fade,
      TextSpan(
        children: [
          for (int i = 0; i < item.texts.length; i++)
            TextSpan(
              text: item.texts[i],
              style: (i % 2 == 0)
                  ? Theme.of(context).textTheme.labelLarge
                  : Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );

    final size = MediaQuery.sizeOf(context);
    final imageWidth = size.width < 430.0 ? size.width * 0.30 : 100.0;

    return DialogBox(
      Padding(
        padding: Theming.paddingAll,
        child: Row(
          children: [
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: CachedImage(
                  item.imageUrl!,
                  width: imageWidth,
                  height: imageWidth * Theming.coverHtoWRatio,
                ),
              ),
              const SizedBox(width: Theming.offset),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: title),
                  if (item.details != null) ...[
                    const SizedBox(height: Theming.offset),
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

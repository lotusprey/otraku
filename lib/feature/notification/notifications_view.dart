import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/notification/notifications_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/notification/notifications_filter_provider.dart';
import 'package:otraku/feature/notification/notifications_model.dart';
import 'package:otraku/feature/notification/notifications_provider.dart';
import 'package:otraku/util/background_handler.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/pill_selector.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/widget/timestamp.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView();

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  late final _scrollCtrl = PagedController(
    loadMore: () => ref.read(notificationsProvider.notifier).fetch(),
  );

  @override
  void initState() {
    super.initState();
    BackgroundHandler.clearNotifications();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(
      notificationsProvider.select((s) => s.value?.total ?? 0),
    );

    final filter = ref.watch(notificationsFilterProvider);

    final analogClock = ref.watch(
      persistenceProvider.select((s) => s.options.analogClock),
    );

    final content = _Content(
      unreadCount: unreadCount,
      analogClock: analogClock,
      scrollCtrl: _scrollCtrl,
    );

    final formFactor = Theming.of(context).formFactor;

    return AdaptiveScaffold(
      topBar: TopBar(
        trailing: [
          Expanded(
            child: Text(
              'Notifications',
              style: TextTheme.of(context).titleLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      floatingAction: formFactor == FormFactor.phone
          ? HidingFloatingActionButton(
              key: const Key('filter'),
              scrollCtrl: _scrollCtrl,
              child: FloatingActionButton(
                tooltip: 'Filter',
                onPressed: _showFilterSheet,
                child: const Icon(Ionicons.funnel_outline),
              ),
            )
          : null,
      child: formFactor == FormFactor.phone
          ? content
          : Row(
              children: [
                PillSelector(
                  selected: filter.index,
                  maxWidth: 120,
                  onTap: (i) => ref.read(notificationsFilterProvider.notifier).state =
                      NotificationsFilter.values[i],
                  items: NotificationsFilter.values.map((v) => Text(v.label)).toList(),
                ),
                Expanded(child: content),
              ],
            ),
    );
  }

  void _showFilterSheet() {
    showSheet(
      context,
      Consumer(
        builder: (context, ref, _) {
          final index = ref.read(notificationsFilterProvider.notifier).state.index;

          return SimpleSheet(
            initialHeight: PillSelector.expectedMinHeight(
              NotificationsFilter.values.length,
            ),
            builder: (context, scrollCtrl) => PillSelector(
              scrollCtrl: scrollCtrl,
              selected: index,
              onTap: (i) {
                ref.read(notificationsFilterProvider.notifier).state =
                    NotificationsFilter.values[i];
                Navigator.pop(context);
              },
              items: NotificationsFilter.values.map((v) => Text(v.label)).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.unreadCount,
    required this.analogClock,
    required this.scrollCtrl,
  });

  final int unreadCount;
  final bool analogClock;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<SiteNotification>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(notificationsProvider),
      provider: notificationsProvider,
      onData: (data) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _NotificationItem(
            data.items[i],
            i < unreadCount,
            analogClock,
          ),
          childCount: data.items.length,
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem(this.item, this.unread, this.analogClock);

  final SiteNotification item;
  final bool unread;
  final bool analogClock;

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
                if (item.imageUrl != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => switch (item) {
                      FollowNotification item => context.push(
                          Routes.user(item.userId, item.imageUrl),
                        ),
                      ActivityNotification item => context.push(
                          Routes.user(item.userId, item.imageUrl),
                        ),
                      ThreadNotification item => context.push(
                          Routes.user(item.userId, item.imageUrl),
                        ),
                      ThreadCommentNotification item => context.push(
                          Routes.user(item.userId, item.imageUrl),
                        ),
                      MediaReleaseNotification item => context.push(
                          Routes.media(item.mediaId, item.imageUrl),
                        ),
                      MediaChangeNotification item => context.push(
                          Routes.media(item.mediaId, item.imageUrl),
                        ),
                      MediaDeletionNotification _ => null,
                    },
                    onLongPress: () => switch (item) {
                      MediaReleaseNotification item => showSheet(
                          context,
                          EditView((id: item.mediaId, setComplete: false)),
                        ),
                      MediaChangeNotification item => showSheet(
                          context,
                          EditView((id: item.mediaId, setComplete: false)),
                        ),
                      _ => null,
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
                    onTap: () => switch (item) {
                      FollowNotification item => context.push(
                          Routes.user(item.userId, item.imageUrl),
                        ),
                      ActivityNotification item => context.push(
                          Routes.activity(item.activityId),
                        ),
                      ThreadNotification item => context.push(
                          Routes.thread(item.threadId),
                        ),
                      ThreadCommentNotification item => context.push(
                          Routes.comment(item.commentId),
                        ),
                      MediaReleaseNotification item => context.push(
                          Routes.media(item.mediaId, item.imageUrl),
                        ),
                      MediaChangeNotification() || MediaDeletionNotification() => showDialog(
                          context: context,
                          builder: (context) => _NotificationDialog(item),
                        ),
                    },
                    onLongPress: () => switch (item) {
                      MediaReleaseNotification item => showSheet(
                          context,
                          EditView((id: item.mediaId, setComplete: false)),
                        ),
                      MediaChangeNotification item => showSheet(
                          context,
                          EditView((id: item.mediaId, setComplete: false)),
                        ),
                      _ => null,
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
                                          ? TextTheme.of(context).labelLarge
                                          : TextTheme.of(context).bodyMedium,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Timestamp(item.createdAt, analogClock),
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
                      color: ColorScheme.of(context).primary,
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
                  ? TextTheme.of(context).labelLarge
                  : TextTheme.of(context).bodyMedium,
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
                  ...switch (item) {
                    MediaChangeNotification item => [
                        const SizedBox(height: Theming.offset),
                        HtmlContent(item.reason),
                      ],
                    MediaDeletionNotification item => [
                        const SizedBox(height: Theming.offset),
                        HtmlContent(item.reason),
                      ],
                    _ => const [],
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

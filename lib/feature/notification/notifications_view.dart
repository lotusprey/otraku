import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
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
    final unreadCount = ref.watch(notificationsProvider.select((s) => s.value?.total ?? 0));

    final filter = ref.watch(notificationsFilterProvider);

    final options = ref.watch(persistenceProvider.select((s) => s.options));

    final content = _Content(
      unreadCount: unreadCount,
      analogClock: options.analogClock,
      highContrast: options.highContrast,
      scrollCtrl: _scrollCtrl,
    );

    final formFactor = Theming.of(context).formFactor;

    return AdaptiveScaffold(
      topBar: const TopBar(title: 'Notifications'),
      floatingAction: formFactor == .phone
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
      child: formFactor == .phone
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
            initialHeight: PillSelector.expectedMinHeight(NotificationsFilter.values.length),
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
    required this.highContrast,
    required this.scrollCtrl,
  });

  final int unreadCount;
  final bool analogClock;
  final bool highContrast;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<SiteNotification>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(notificationsProvider),
      provider: notificationsProvider,
      onData: (data) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) =>
              _NotificationItem(data.items[i], i < unreadCount, analogClock, highContrast),
          childCount: data.items.length,
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem(this.item, this.unread, this.analogClock, this.highContrast);

  final SiteNotification item;
  final bool unread;
  final bool analogClock;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final bodyMediumStyle = textTheme.bodyMedium!;
    final accentedStyle = bodyMediumStyle.copyWith(color: ColorScheme.of(context).primary);

    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelSmallLineHeight = context.lineHeight(textTheme.labelSmall!);
    final height = bodyMediumLineHeight * 2 + max(labelSmallLineHeight, Theming.iconSmall) + 23;

    return SizedBox(
      height: height + 10,
      child: CardExtension.highContrast(highContrast)(
        margin: const .only(bottom: Theming.offset),
        child: Row(
          children: [
            if (item.imageUrl != null)
              GestureDetector(
                behavior: .opaque,
                onTap: () => switch (item) {
                  FollowNotification item => context.push(Routes.user(item.userId, item.imageUrl)),
                  ActivityNotification item => context.push(
                    Routes.user(item.userId, item.imageUrl),
                  ),
                  ThreadNotification item => context.push(Routes.user(item.userId, item.imageUrl)),
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
                  borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                  child: CachedImage(item.imageUrl!, width: height / Theming.coverHtoWRatio),
                ),
              ),
            Flexible(
              child: GestureDetector(
                behavior: .opaque,
                onTap: () => switch (item) {
                  FollowNotification item => context.push(Routes.user(item.userId, item.imageUrl)),
                  ActivityNotification item => context.push(Routes.activity(item.activityId)),
                  ThreadNotification item => context.push(Routes.thread(item.threadId)),
                  ThreadCommentNotification item => context.push(Routes.comment(item.commentId)),
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
                    mainAxisAlignment: .spaceEvenly,
                    crossAxisAlignment: .stretch,
                    spacing: 3,
                    children: [
                      Flexible(
                        child: Text.rich(
                          overflow: .ellipsis,
                          maxLines: 2,
                          TextSpan(
                            children: [
                              for (int i = 0; i < item.texts.length; i++)
                                TextSpan(
                                  text: item.texts[i],
                                  style: (i % 2 == 0) ? accentedStyle : bodyMediumStyle,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Timestamp(item.createdAt, analogClock),
                    ],
                  ),
                ),
              ),
            ),
            if (unread)
              Container(
                height: height,
                width: Theming.offset,
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).primary,
                  borderRadius: const BorderRadius.horizontal(right: Theming.radiusSmall),
                ),
              ),
          ],
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
    final bodyMediumStyle = TextTheme.of(context).bodyMedium!;
    final accentedStyle = bodyMediumStyle.copyWith(color: ColorScheme.of(context).primary);

    final title = Text.rich(
      overflow: .ellipsis,
      TextSpan(
        children: [
          for (int i = 0; i < item.texts.length; i++)
            TextSpan(text: item.texts[i], style: (i % 2 == 0) ? accentedStyle : bodyMediumStyle),
        ],
      ),
    );

    final size = MediaQuery.sizeOf(context);
    final imageWidth = size.width < 430.0 ? size.width * 0.30 : 100.0;

    return DialogBox(
      Padding(
        padding: Theming.paddingAll,
        child: Row(
          spacing: Theming.offset,
          children: [
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: CachedImage(
                  item.imageUrl!,
                  width: imageWidth,
                  height: imageWidth * Theming.coverHtoWRatio,
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: .min,
                spacing: Theming.offset,
                children: [
                  Flexible(child: title),
                  ...switch (item) {
                    MediaChangeNotification item => [HtmlContent(item.reason)],
                    MediaDeletionNotification item => [HtmlContent(item.reason)],
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

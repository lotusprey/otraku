import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/comment/comment_tile.dart';
import 'package:otraku/feature/forum/forum_filter_model.dart';
import 'package:otraku/feature/forum/forum_filter_provider.dart';
import 'package:otraku/feature/thread/thread_model.dart';
import 'package:otraku/feature/thread/thread_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/timestamp.dart';

class ThreadView extends ConsumerStatefulWidget {
  const ThreadView(this.id);

  final int id;

  @override
  ConsumerState<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends ConsumerState<ThreadView> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      threadProvider(widget.id),
      (_, s) =>
          s.whenOrNull(error: (error, _) => SnackBarExtension.show(context, error.toString())),
    );

    final thread = ref.watch(threadProvider(widget.id));
    final options = ref.watch(persistenceProvider.select((s) => s.options));
    final viewerId = ref.watch(viewerIdProvider);

    return AdaptiveScaffold(
      topBar: TopBar(
        trailing: thread.hasValue
            ? _topBarTrailingContent(thread.value!, viewerId)
            : const <Widget>[],
      ),
      floatingAction: HidingFloatingActionButton(
        key: const Key('Reply'),
        scrollCtrl: _scrollCtrl,
        child: FloatingActionButton(
          tooltip: 'New Reply',
          child: const Icon(Icons.edit_outlined),
          onPressed: () => showSheet(
            context,
            CompositionView(
              tag: CommentCompositionTag(threadId: widget.id, parentCommentId: null),
              onSaved: (map) =>
                  ref.read(threadProvider(widget.id).notifier).appendComment(map, null),
            ),
          ),
        ),
      ),
      bottomBar: thread.hasValue && thread.value!.totalCommentPages > 1
          ? _BottomBar(
              thread: thread.value!,
              changePage: (page) => ref.read(threadProvider(widget.id).notifier).changePage(page),
            )
          : null,
      child: ConstrainedView(
        child: switch (thread.unwrapPrevious()) {
          AsyncData(:final value) => _Content(ref, value, options.analogClock, _scrollCtrl),
          AsyncError() => CustomScrollView(
            physics: Theming.bouncyPhysics,
            slivers: [
              SliverRefreshControl(onRefresh: () => ref.invalidate(threadProvider(widget.id))),
              const SliverFillRemaining(child: Center(child: Text('Failed to load'))),
            ],
          ),
          AsyncLoading() => const Center(child: Loader()),
        },
      ),
    );
  }

  List<Widget> _topBarTrailingContent(Thread thread, int? viewerId) => [
    Expanded(
      child: GestureDetector(
        behavior: .opaque,
        onTap: () => context.push(Routes.user(thread.info.userId, thread.info.userAvatarUrl)),
        child: Row(
          mainAxisSize: .min,
          children: [
            Hero(
              tag: thread.info.userId,
              child: ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: CachedImage(thread.info.userAvatarUrl, height: 40, width: 40),
              ),
            ),
            const SizedBox(width: Theming.offset),
            Flexible(child: Text(thread.info.userName, overflow: .ellipsis, maxLines: 1)),
          ],
        ),
      ),
    ),
    IconButton(
      tooltip: 'More',
      icon: const Icon(Ionicons.ellipsis_horizontal),
      onPressed: () => showSheet(
        context,
        SimpleSheet.link(context, thread.info.siteUrl, [
          ListTile(
            title: !thread.info.isSubscribed ? const Text('Subscribe') : const Text('Unsubscribe'),
            leading: !thread.info.isSubscribed
                ? const Icon(Ionicons.notifications_outline)
                : const Icon(Ionicons.notifications_off_outline),
            onTap: _toggleSubscription,
          ),
          if (viewerId == thread.info.userId)
            ListTile(
              title: const Text('Delete'),
              leading: const Icon(Ionicons.trash_outline),
              onTap: () {
                Navigator.pop(context);

                ConfirmationDialog.show(
                  context,
                  title: 'Delete?',
                  primaryAction: 'Yes',
                  secondaryAction: 'No',
                  onConfirm: _delete,
                );
              },
            ),
        ]),
      ),
    ),
  ];

  void _toggleSubscription() async {
    final err = await ref.read(threadProvider(widget.id).notifier).toggleThreadSubscription();

    if (!mounted) return;

    if (err == null) {
      Navigator.pop(context);
      return;
    }

    SnackBarExtension.show(context, err.toString());
    Navigator.pop(context);
  }

  void _delete() async {
    final err = await ref.read(threadProvider(widget.id).notifier).delete();

    if (!mounted) return;

    if (err == null) {
      Navigator.pop(context);
      return;
    }

    SnackBarExtension.show(context, 'Failed deleting thread: $err');
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar({required this.thread, required this.changePage});

  final Thread thread;
  final void Function(int page) changePage;

  @override
  State<_BottomBar> createState() => __BottomBarState();
}

class __BottomBarState extends State<_BottomBar> {
  late var _value = widget.thread.commentPage;

  @override
  void didUpdateWidget(covariant _BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.thread.commentPage;
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;

    final currentPageLabel = Text('$_value');
    final previousPageButton = IconButton(
      tooltip: 'Previous page',
      icon: const Icon(Icons.arrow_back_ios_rounded),
      onPressed: thread.commentPage == 1 ? null : () => widget.changePage(thread.commentPage - 1),
    );
    final nextPageButton = IconButton(
      tooltip: 'Next page',
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: thread.commentPage == thread.totalCommentPages
          ? null
          : () => widget.changePage(thread.commentPage + 1),
    );
    final pageSlider = Expanded(
      child: Slider.adaptive(
        min: 1,
        max: thread.totalCommentPages.toDouble(),
        value: _value.toDouble(),
        onChanged: (value) => setState(() => _value = value.round()),
        onChangeEnd: (value) => widget.changePage(value.round()),
      ),
    );

    final bottomBarItems = Theming.of(context).rightButtonOrientation
        ? [pageSlider, previousPageButton, currentPageLabel, nextPageButton]
        : [previousPageButton, currentPageLabel, nextPageButton, pageSlider];

    return BottomBar(bottomBarItems);
  }
}

class _Content extends StatelessWidget {
  const _Content(this.ref, this.thread, this.analogClock, this.scrollCtrl);

  final WidgetRef ref;
  final Thread thread;
  final bool analogClock;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final viewerId = ref.watch(viewerIdProvider);
    const spacing = SliverToBoxAdapter(child: SizedBox(height: Theming.offset));
    final info = thread.info;

    return CustomScrollView(
      controller: scrollCtrl,
      physics: Theming.bouncyPhysics,
      slivers: [
        SliverRefreshControl(onRefresh: () => ref.invalidate(threadProvider(thread.info.id))),
        SliverToBoxAdapter(child: Timestamp(info.createdAt, analogClock)),
        spacing,
        SliverToBoxAdapter(child: Text(thread.info.title, style: TextTheme.of(context).titleLarge)),
        spacing,
        HtmlContent(thread.info.body, renderMode: RenderMode.sliverList),
        spacing,
        if (info.media.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: Theming.minTapTarget,
              child: ShadowedOverflowList(
                itemCount: info.media.length,
                itemBuilder: (context, i) {
                  final media = info.media[i];

                  return ActionChip(
                    label: Text(media.title),
                    avatar: CachedImage(media.coverUrl),
                    onPressed: () => context.push(Routes.media(media.id)),
                  );
                },
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: Theming.minTapTarget,
            child: ShadowedOverflowList(
              itemCount: info.categories.length,
              itemBuilder: (context, i) {
                final label = info.categories[i];

                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    context.push(Routes.forum);

                    ref.invalidate(forumFilterProvider);
                    ref
                        .read(forumFilterProvider.notifier)
                        .update(
                          (filter) => filter.copyWith(category: (ThreadCategory.from(label),)),
                        );
                  },
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const .symmetric(vertical: Theming.offset),
            child: Row(
              spacing: Theming.offset,
              children: [
                if (info.isPinned)
                  Tooltip(
                    message: 'Pinned',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(Icons.push_pin_outlined, size: Theming.iconSmall),
                  ),
                if (info.isLocked)
                  Tooltip(
                    message: 'Locked',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(Icons.lock_outline_rounded, size: Theming.iconSmall),
                  ),
                const Spacer(),
                Tooltip(
                  message: 'Views',
                  triggerMode: TooltipTriggerMode.tap,
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        info.viewCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.remove_red_eye_outlined, size: Theming.iconSmall),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Replies',
                  triggerMode: TooltipTriggerMode.tap,
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        info.replyCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.reply_all_rounded, size: Theming.iconSmall),
                    ],
                  ),
                ),
                _LikeButton(ref, info),
              ],
            ),
          ),
        ),
        spacing,
        SliverList.builder(
          itemCount: thread.comments.length,
          itemBuilder: (context, i) {
            final comment = thread.comments[i];

            return Padding(
              padding: const .only(bottom: Theming.offset),
              child: CommentTile(
                comment,
                viewerId: viewerId,
                analogClock: analogClock,
                interaction: (
                  onReplySaved: (map, commentId) =>
                      ref.read(threadProvider(info.id).notifier).appendComment(map, commentId),
                  toggleLike: (commentId) =>
                      ref.read(threadProvider(info.id).notifier).toggleCommentLike(commentId),
                ),
              ),
            );
          },
        ),
        const SliverFooter(),
      ],
    );
  }
}

class _LikeButton extends StatefulWidget {
  const _LikeButton(this.ref, this.threadInfo);

  final WidgetRef ref;
  final ThreadInfo threadInfo;

  @override
  State<_LikeButton> createState() => __LikeButtonState();
}

class __LikeButtonState extends State<_LikeButton> {
  @override
  Widget build(BuildContext context) {
    final info = widget.threadInfo;

    return Tooltip(
      message: !info.isLiked ? 'Like' : 'Unlike',
      child: InkResponse(
        radius: Theming.radiusSmall.x,
        onTap: () async {
          final prevIsLiked = info.isLiked;
          final prevLikeCount = info.likeCount;

          setState(() {
            info.isLiked = !prevIsLiked;
            info.likeCount = prevLikeCount + 1;
          });

          final err = await widget.ref.read(threadProvider(info.id).notifier).toggleThreadLike();

          if (err == null) return;

          setState(() {
            info.isLiked = prevIsLiked;
            info.likeCount = prevLikeCount;
          });

          if (context.mounted) {
            SnackBarExtension.show(context, err.toString());
          }
        },
        child: Row(
          children: [
            Text(
              info.likeCount.toString(),
              style: !info.isLiked
                  ? TextTheme.of(context).labelSmall
                  : TextTheme.of(
                      context,
                    ).labelSmall!.copyWith(color: ColorScheme.of(context).primary),
            ),
            const SizedBox(width: 5),
            Icon(
              !info.isLiked ? Icons.favorite_outline_rounded : Icons.favorite_rounded,
              size: Theming.iconSmall,
              color: info.isLiked ? ColorScheme.of(context).primary : null,
            ),
          ],
        ),
      ),
    );
  }
}

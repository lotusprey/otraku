import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/comment/comment_model.dart';
import 'package:otraku/feature/comment/comment_provider.dart';
import 'package:otraku/feature/comment/comment_tile.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/sheets.dart';

class CommentView extends ConsumerStatefulWidget {
  const CommentView(this.id);

  final int id;

  @override
  ConsumerState<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends ConsumerState<CommentView> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      commentProvider(widget.id),
      (_, s) =>
          s.whenOrNull(error: (error, _) => SnackBarExtension.show(context, error.toString())),
    );

    final comment = ref.watch(commentProvider(widget.id));
    final viewerId = ref.watch(viewerIdProvider);
    final options = ref.watch(persistenceProvider.select((s) => s.options));

    TopBar? topBar;
    void Function()? floatingActionOnPressed;

    if (comment.hasValue) {
      final value = comment.value!;

      topBar = TopBar(trailing: _topBarTrailingContent(context, ref, value, viewerId));

      floatingActionOnPressed = () => showSheet(
        context,
        CompositionView(
          tag: CommentCompositionTag(threadId: value.threadId, parentCommentId: value.id),
          onSaved: (map) =>
              ref.read(commentProvider(widget.id).notifier).appendComment(map, value.id),
        ),
      );
    }

    return AdaptiveScaffold(
      topBar: topBar ?? const TopBar(),
      floatingAction: HidingFloatingActionButton(
        key: const Key('Reply'),
        scrollCtrl: _scrollCtrl,
        child: FloatingActionButton(
          tooltip: 'New Reply',
          onPressed: floatingActionOnPressed,
          child: const Icon(Icons.edit_outlined),
        ),
      ),
      child: ConstrainedView(
        child: switch (comment.unwrapPrevious()) {
          AsyncData(:final value) => _Content(
            ref,
            value,
            options.highContrast,
            options.analogClock,
          ),
          AsyncError() => CustomScrollView(
            physics: Theming.bouncyPhysics,
            slivers: [
              SliverRefreshControl(onRefresh: () => ref.invalidate(commentProvider(widget.id))),
              const SliverFillRemaining(child: Center(child: Text('Failed to load'))),
            ],
          ),
          AsyncLoading() => const Center(child: Loader()),
        },
      ),
    );
  }

  List<Widget> _topBarTrailingContent(
    BuildContext context,
    WidgetRef ref,
    Comment comment,
    int? viewerId,
  ) => [
    const Spacer(),
    IconButton(
      tooltip: 'More',
      icon: const Icon(Ionicons.ellipsis_horizontal),
      onPressed: () => showSheet(
        context,
        SimpleSheet.link(
          context,
          comment.siteUrl,
          viewerId == comment.userId
              ? [
                  ListTile(
                    title: const Text('Edit'),
                    leading: const Icon(Icons.edit_outlined),
                    onTap: () => showSheet(
                      context,
                      CompositionView(
                        tag: CommentCompositionTag.edit(id: comment.id, threadId: comment.threadId),
                        onSaved: (map) {
                          ref.read(commentProvider(widget.id).notifier).edit(map);

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
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
                        onConfirm: () async {
                          final err = await ref.read(commentProvider(widget.id).notifier).delete();

                          if (!context.mounted) return;

                          if (err == null) {
                            Navigator.pop(context);
                            return;
                          }

                          SnackBarExtension.show(context, 'Failed deleting comment: $err');
                        },
                      );
                    },
                  ),
                ]
              : const [],
        ),
      ),
    ),
  ];
}

class _Content extends StatelessWidget {
  const _Content(this.ref, this.comment, this.highContrast, this.analogClock);

  final WidgetRef ref;
  final Comment comment;
  final bool highContrast;
  final bool analogClock;

  @override
  Widget build(BuildContext context) {
    final openThread = () => context.push(Routes.thread(comment.threadId));

    return CustomScrollView(
      physics: Theming.bouncyPhysics,
      slivers: [
        SliverRefreshControl(onRefresh: () => ref.invalidate(commentProvider(comment.id))),
        SliverToBoxAdapter(
          child: Semantics(
            onTap: openThread,
            onTapHint: 'open thread',
            child: GestureDetector(
              onTap: openThread,
              behavior: .opaque,
              child: Text(comment.threadTitle, style: TextTheme.of(context).bodyMedium),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
        SliverToBoxAdapter(
          child: CommentTile(
            comment,
            viewerId: ref.watch(viewerIdProvider),
            highContrast: highContrast,
            analogClock: analogClock,
            interaction: (
              onReplySaved: (map, commentId) =>
                  ref.read(commentProvider(comment.id).notifier).appendComment(map, commentId),
              toggleLike: (commentId) =>
                  ref.read(commentProvider(comment.id).notifier).toggleCommentLike(commentId),
            ),
          ),
        ),
        const SliverFooter(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/comment/comment_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/timestamp.dart';

const _maxCommentDepth = 6;

typedef CommentTileInteraction = ({
  void Function(Map<String, dynamic> map, int commentId) onReplySaved,
  Future<Object?> Function(int commentId) toggleLike,
});

class CommentTile extends StatelessWidget {
  const CommentTile(
    this.comment, {
    required this.viewerId,
    required this.analogClock,
    this.interaction,
    this.depth = 0,
  });

  final Comment comment;
  final CommentTileInteraction? interaction;
  final int? viewerId;
  final bool analogClock;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final userRow = Row(
      children: [
        GestureDetector(
          onTap: () => context.push(Routes.user(comment.userId, comment.userAvatarUrl)),
          child: ClipRRect(
            borderRadius: Theming.borderRadiusSmall,
            child: CachedImage(comment.userAvatarUrl, height: 50, width: 50),
          ),
        ),
        const SizedBox(width: Theming.offset),
        Expanded(
          child: OverflowBar(
            spacing: 5,
            overflowSpacing: 5,
            children: [
              Text(comment.userName, overflow: .ellipsis, maxLines: 1),
              Timestamp(
                comment.createdAt,
                analogClock,
                leading: Text('replied', style: TextTheme.of(context).labelSmall),
              ),
            ],
          ),
        ),
      ],
    );

    final contentColumn = Padding(
      padding: const .only(left: Theming.offset, top: Theming.offset),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Padding(padding: const .only(right: 10, bottom: 5), child: HtmlContent(comment.text)),
          Padding(
            padding: const .only(right: 10, bottom: 10),
            child: Row(
              spacing: Theming.offset,
              children: [
                if (comment.isLocked)
                  Tooltip(
                    message: 'Locked',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(Icons.lock_outline_rounded, size: Theming.iconSmall),
                  ),
                const Spacer(),
                if (interaction != null) ...[
                  if (comment.userId != viewerId)
                    Tooltip(
                      message: 'Reply',
                      child: InkResponse(
                        radius: Theming.radiusSmall.x,
                        onTap: () => showSheet(
                          context,
                          CompositionView(
                            tag: CommentCompositionTag(
                              threadId: comment.threadId,
                              parentCommentId: comment.id,
                            ),
                            onSaved: (map) => interaction!.onReplySaved(map, comment.id),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              comment.childComments.length.toString(),
                              style: TextTheme.of(context).labelSmall,
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.reply_all_rounded, size: Theming.iconSmall),
                          ],
                        ),
                      ),
                    )
                  else
                    Tooltip(
                      message: 'Replies',
                      child: InkResponse(
                        radius: Theming.radiusSmall.x,
                        onTap: () => context.push(Routes.comment(comment.id)),
                        child: Row(
                          children: [
                            Text(
                              comment.childComments.length.toString(),
                              style: TextTheme.of(context).labelSmall,
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.reply_all_rounded, size: Theming.iconSmall),
                          ],
                        ),
                      ),
                    ),
                  _LikeButton(comment, interaction!.toggleLike),
                ] else ...[
                  SizedBox(
                    height: 20,
                    child: Tooltip(
                      message: 'Replies',
                      child: InkResponse(
                        radius: Theming.radiusSmall.x,
                        onTap: () => context.push(Routes.comment(comment.id)),
                        child: const Icon(Icons.reply_all_rounded, size: Theming.iconSmall),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Likes',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Text(
                          comment.likeCount.toString(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.favorite_outline_rounded, size: Theming.iconSmall),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (comment.childComments.isNotEmpty)
            depth < _maxCommentDepth
                ? Column(
                    spacing: Theming.offset,
                    mainAxisSize: .min,
                    children: comment.childComments
                        .map(
                          (c) => CommentTile(
                            c,
                            viewerId: viewerId,
                            analogClock: analogClock,
                            interaction: interaction,
                            depth: depth + 1,
                          ),
                        )
                        .toList(),
                  )
                : TextButton(
                    onPressed: () => context.push(Routes.comment(comment.id)),
                    child: Text(
                      comment.childComments.length > 1
                          ? '${comment.childComments.length} replies'
                          : '1 reply',
                    ),
                  ),
        ],
      ),
    );

    return Column(
      spacing: Theming.offset,
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        userRow,
        if (depth == 0) Card(child: contentColumn) else Card.outlined(child: contentColumn),
      ],
    );
  }
}

class _LikeButton extends StatefulWidget {
  const _LikeButton(this.comment, this.toggleLike);

  final Comment comment;
  final Future<Object?> Function(int commentId) toggleLike;

  @override
  State<_LikeButton> createState() => __LikeButtonState();
}

class __LikeButtonState extends State<_LikeButton> {
  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    return Tooltip(
      message: !comment.isLiked ? 'Like' : 'Unlike',
      child: InkResponse(
        radius: Theming.radiusSmall.x,
        onTap: () async {
          final prevIsLiked = comment.isLiked;
          final prevLikeCount = comment.likeCount;

          setState(() {
            comment.isLiked = !prevIsLiked;
            comment.likeCount = prevLikeCount + 1;
          });

          final err = await widget.toggleLike(comment.id);
          if (err == null) return;

          setState(() {
            comment.isLiked = prevIsLiked;
            comment.likeCount = prevLikeCount;
          });

          if (context.mounted) {
            SnackBarExtension.show(context, err.toString());
          }
        },
        child: Row(
          children: [
            Text(
              comment.likeCount.toString(),
              style: !comment.isLiked
                  ? TextTheme.of(context).labelSmall
                  : TextTheme.of(
                      context,
                    ).labelSmall!.copyWith(color: ColorScheme.of(context).primary),
            ),
            const SizedBox(width: 5),
            Icon(
              !comment.isLiked ? Icons.favorite_outline_rounded : Icons.favorite_rounded,
              size: Theming.iconSmall,
              color: comment.isLiked ? ColorScheme.of(context).primary : null,
            ),
          ],
        ),
      ),
    );
  }
}

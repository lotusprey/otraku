import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/activity/activity_provider.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/toast.dart';
import 'package:otraku/widget/link_tile.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard({
    required this.activityId,
    required this.reply,
    required this.toggleLike,
  });

  final int activityId;
  final ActivityReply reply;
  final Future<Object?> Function() toggleLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinkTile(
          id: reply.authorId,
          info: reply.authorAvatarUrl,
          discoverType: DiscoverType.user,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: CachedImage(
                  reply.authorAvatarUrl,
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(width: Theming.offset),
              Text(reply.authorName),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Card(
          margin: const EdgeInsets.only(bottom: Theming.offset),
          child: Padding(
            padding: const EdgeInsets.only(
              top: Theming.offset,
              left: Theming.offset,
              right: Theming.offset,
            ),
            child: Column(
              children: [
                UnconstrainedBox(
                  constrainedAxis: Axis.horizontal,
                  alignment: Alignment.topLeft,
                  child: HtmlContent(reply.text),
                ),
                Row(
                  children: [
                    Text(
                      reply.createdAt,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, _) => SizedBox(
                        height: 40,
                        child: reply.authorId == Persistence().id
                            ? Tooltip(
                                message: 'More',
                                child: InkResponse(
                                  radius: Theming.radiusSmall.x,
                                  onTap: () => _showMoreSheet(context, ref),
                                  child: const Icon(
                                    Ionicons.ellipsis_horizontal,
                                    size: Theming.iconSmall,
                                  ),
                                ),
                              )
                            : _ReplyMentionButton(
                                ref,
                                activityId,
                                reply.authorName,
                              ),
                      ),
                    ),
                    const SizedBox(width: Theming.offset),
                    _ReplyLikeButton(reply: reply, toggleLike: toggleLike),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Show a sheet with additional options.
  void _showMoreSheet(BuildContext context, WidgetRef ref) {
    showSheet(
      context,
      GradientSheet([
        GradientSheetButton(
          text: 'Edit',
          icon: Icons.edit_outlined,
          onTap: () => showSheet(
            context,
            CompositionView(
              tag: ActivityReplyCompositionTag(
                id: reply.id,
                activityId: activityId,
              ),
              onSaved: (map) => ref
                  .read(activityProvider(activityId).notifier)
                  .replaceReply(map),
            ),
          ),
        ),
        GradientSheetButton(
          text: 'Delete',
          icon: Ionicons.trash_outline,
          onTap: () => showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Delete?',
              mainAction: 'Yes',
              secondaryAction: 'No',
              onConfirm: () {
                ref
                    .read(activityProvider(activityId).notifier)
                    .removeReply(reply.id)
                    .then((err) {
                  if (err == null) return;

                  showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      title: 'Could not delete reply',
                      content: err.toString(),
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ]),
    );
  }
}

class _ReplyMentionButton extends StatelessWidget {
  const _ReplyMentionButton(this.ref, this.activityId, this.username);

  final WidgetRef ref;
  final int activityId;
  final String username;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Tooltip(
        message: 'Reply',
        child: InkResponse(
          radius: Theming.radiusSmall.x,
          onTap: () => showSheet(
            context,
            CompositionView(
              defaultText: '@$username ',
              tag: ActivityReplyCompositionTag(
                id: null,
                activityId: activityId,
              ),
              onSaved: (map) => ref
                  .read(activityProvider(activityId).notifier)
                  .appendReply(map),
            ),
          ),
          child: const Icon(
            Icons.reply_outlined,
            size: Theming.iconSmall,
          ),
        ),
      ),
    );
  }
}

class _ReplyLikeButton extends StatefulWidget {
  const _ReplyLikeButton({required this.reply, required this.toggleLike});

  final ActivityReply reply;
  final Future<Object?> Function() toggleLike;

  @override
  _ReplyLikeButtonState createState() => _ReplyLikeButtonState();
}

class _ReplyLikeButtonState extends State<_ReplyLikeButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Tooltip(
        message: !widget.reply.isLiked ? 'Like' : 'Unlike',
        child: InkResponse(
          radius: Theming.radiusSmall.x,
          onTap: _toggleLike,
          child: Row(
            children: [
              Text(
                widget.reply.likeCount.toString(),
                style: !widget.reply.isLiked
                    ? Theme.of(context).textTheme.labelSmall
                    : Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.favorite_rounded,
                size: Theming.iconSmall,
                color: widget.reply.isLiked
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleLike() async {
    final reply = widget.reply;
    final isLiked = reply.isLiked;

    setState(() {
      reply.isLiked = !isLiked;
      reply.likeCount += isLiked ? -1 : 1;
    });

    final err = await widget.toggleLike();
    if (err == null) return;

    setState(() {
      reply.isLiked = isLiked;
      reply.likeCount += isLiked ? 1 : -1;
    });

    if (mounted) Toast.show(context, err.toString());
  }
}

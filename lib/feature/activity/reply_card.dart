import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/activity/activity_provider.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/timestamp.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard({
    required this.activityId,
    required this.reply,
    required this.analogClock,
    required this.highContrast,
    required this.toggleLike,
  });

  final int activityId;
  final ActivityReply reply;
  final bool analogClock;
  final bool highContrast;
  final Future<Object?> Function() toggleLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(
            Routes.user(reply.authorId, reply.authorAvatarUrl),
          ),
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
        CardExtension.highContrast(highContrast)(
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
                    Timestamp(reply.createdAt, analogClock),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, _) => SizedBox(
                        height: 40,
                        child: reply.authorId == ref.watch(viewerIdProvider)
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
      SimpleSheet.list(
        [
          ListTile(
            title: const Text('Edit'),
            leading: const Icon(Icons.edit_outlined),
            onTap: () => showSheet(
              context,
              CompositionView(
                tag: ActivityReplyCompositionTag(
                  id: reply.id,
                  activityId: activityId,
                ),
                onSaved: (map) {
                  ref.read(activityProvider(activityId).notifier).replaceReply(map);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Delete'),
            leading: const Icon(Ionicons.trash_outline),
            onTap: () => ConfirmationDialog.show(
              context,
              title: 'Delete?',
              primaryAction: 'Yes',
              secondaryAction: 'No',
              onConfirm: () async {
                final err =
                    await ref.read(activityProvider(activityId).notifier).removeReply(reply.id);

                if (err == null) {
                  if (context.mounted) Navigator.pop(context);
                  return;
                }

                if (context.mounted) {
                  SnackBarExtension.show(context, err.toString());
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
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
              onSaved: (map) => ref.read(activityProvider(activityId).notifier).appendReply(map),
            ),
          ),
          child: const Icon(Icons.reply_rounded, size: Theming.iconSmall),
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
                    ? TextTheme.of(context).labelSmall
                    : TextTheme.of(context)
                        .labelSmall!
                        .copyWith(color: ColorScheme.of(context).primary),
              ),
              const SizedBox(width: 5),
              Icon(
                !widget.reply.isLiked ? Icons.favorite_outline_rounded : Icons.favorite_rounded,
                size: Theming.iconSmall,
                color: widget.reply.isLiked ? ColorScheme.of(context).primary : null,
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

    if (mounted) SnackBarExtension.show(context, err.toString());
  }
}

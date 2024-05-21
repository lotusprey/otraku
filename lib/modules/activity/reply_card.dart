import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/activity/activity_models.dart';
import 'package:otraku/modules/activity/activity_provider.dart';
import 'package:otraku/modules/composition/composition_model.dart';
import 'package:otraku/modules/composition/composition_view.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard(this.activityId, this.reply);

  final int activityId;
  final ActivityReply reply;

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
                borderRadius: Consts.borderRadiusMin,
                child: CachedImage(
                  reply.authorAvatarUrl,
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(width: 10),
              Text(reply.authorName),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                                  radius: 10,
                                  onTap: () => _showMoreSheet(context, ref),
                                  child: const Icon(
                                    Ionicons.ellipsis_horizontal,
                                    size: Consts.iconSmall,
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
                    const SizedBox(width: 10),
                    _ReplyLikeButton(reply),
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
          onTap: () => showPopUp(
            context,
            ConfirmationDialog(
              title: 'Delete?',
              mainAction: 'Yes',
              secondaryAction: 'No',
              onConfirm: () {
                deleteActivityReply(reply.id).then((err) {
                  if (err == null) {
                    ref
                        .read(activityProvider(activityId).notifier)
                        .removeReply(reply.id);
                  } else {
                    showPopUp(
                      context,
                      ConfirmationDialog(
                        title: 'Could not delete reply',
                        content: err.toString(),
                      ),
                    );
                  }
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
          radius: 10,
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
            Icons.reply,
            size: Consts.iconSmall,
          ),
        ),
      ),
    );
  }
}

class _ReplyLikeButton extends StatefulWidget {
  const _ReplyLikeButton(this.reply);

  final ActivityReply reply;

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
          radius: 10,
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
                        .copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.favorite,
                size: Consts.iconSmall,
                color: widget.reply.isLiked
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Toggle a like and revert the change,
  /// if the reqest was unsuccessful.
  void _toggleLike() {
    final reply = widget.reply;
    final isLiked = reply.isLiked;

    setState(() {
      reply.isLiked = !isLiked;
      reply.likeCount += isLiked ? -1 : 1;
    });

    toggleReplyLike(reply).then((err) {
      if (err == null) return;

      setState(() {
        reply.isLiked = isLiked;
        reply.likeCount += isLiked ? 1 : -1;
      });

      showPopUp(
        context,
        ConfirmationDialog(
          title: 'Could not toggle reply like',
          content: err.toString(),
        ),
      );
    });
  }
}

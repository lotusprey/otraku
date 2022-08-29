import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activity_models.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/composition/composition_model.dart';
import 'package:otraku/composition/composition_view.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

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
          id: reply.user.id,
          info: reply.user.imageUrl,
          discoverType: DiscoverType.user,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: FadeImage(
                  reply.user.imageUrl,
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(width: 10),
              Text(reply.user.name),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: Consts.padding,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: Consts.borderRadiusMin,
          ),
          child: Column(
            children: [
              UnconstrainedBox(
                constrainedAxis: Axis.horizontal,
                alignment: Alignment.topLeft,
                child: HtmlContent(reply.text),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    reply.createdAt,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  const Spacer(),
                  if (reply.user.id == Settings().id)
                    Consumer(
                      builder: (context, ref, _) => IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        splashColor: Colors.transparent,
                        tooltip: 'More',
                        constraints: const BoxConstraints(
                          maxHeight: Consts.iconSmall,
                        ),
                        icon: const Icon(
                          Ionicons.ellipsis_horizontal,
                          size: Consts.iconSmall,
                        ),
                        onPressed: () => _showMoreSheet(context, ref),
                      ),
                    ),
                  _ReplyLikeButton(reply),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show a sheet with additional options.
  void _showMoreSheet(BuildContext context, WidgetRef ref) {
    showSheet(
      context,
      FixedGradientDragSheet(
        children: [
          FixedGradientSheetTile(
            text: 'Edit',
            icon: Icons.edit_outlined,
            onTap: () => showSheet(
              context,
              CompositionView(
                composition:
                    Composition.reply(reply.id, reply.text, activityId),
                onDone: (map) => ref
                    .read(activityProvider(activityId).notifier)
                    .replaceReply(map),
              ),
            ),
          ),
          FixedGradientSheetTile(
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
        ],
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
    return Tooltip(
      message: !widget.reply.isLiked ? 'Like' : 'Unlike',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleLike,
        child: Row(
          children: [
            Text(
              widget.reply.likeCount.toString(),
              style: !widget.reply.isLiked
                  ? Theme.of(context).textTheme.subtitle2
                  : Theme.of(context)
                      .textTheme
                      .subtitle2!
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

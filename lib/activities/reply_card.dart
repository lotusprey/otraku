import 'package:flutter/material.dart';
import 'package:otraku/activities/activity.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';

class ReplyCard extends StatelessWidget {
  ReplyCard(this.reply);

  final ActivityReply reply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExploreIndexer(
          id: reply.user.id,
          text: reply.user.imageUrl,
          explorable: Explorable.user,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reply.createdAt,
                    style: Theme.of(context).textTheme.subtitle2,
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
}

class _ReplyLikeButton extends StatefulWidget {
  _ReplyLikeButton(this.reply);

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

    toggleReplyLike(reply).then((ok) {
      if (ok) return;

      setState(() {
        reply.isLiked = isLiked;
        reply.likeCount += isLiked ? 1 : -1;
      });
    });
  }
}

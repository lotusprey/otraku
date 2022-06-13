import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activities/activity.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.activity,
    required this.footer,
    required this.withHeader,
  });

  final Activity activity;
  final ActivityFooter footer;
  final bool withHeader;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: Consts.padding,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: Consts.borderRadiusMin,
      ),
      child: Column(
        children: [
          if (activity.media != null)
            _ActivityMediaBox(activity.media!, activity.text)
          else
            UnconstrainedBox(
              constrainedAxis: Axis.horizontal,
              alignment: Alignment.topLeft,
              child: HtmlContent(activity.text),
            ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  activity.createdAt,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              footer,
            ],
          ),
        ],
      ),
    );

    if (!withHeader) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: ExploreIndexer(
                id: activity.agent.id,
                text: activity.agent.imageUrl,
                explorable: Explorable.user,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: FadeImage(
                        activity.agent.imageUrl,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        activity.agent.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (activity.reciever != null) ...[
              if (activity.isPrivate)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Ionicons.eye_off_outline),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_right_alt),
              ),
              ExploreIndexer(
                id: activity.reciever!.id,
                text: activity.reciever!.imageUrl,
                explorable: Explorable.user,
                child: ClipRRect(
                  borderRadius: Consts.borderRadiusMin,
                  child: FadeImage(
                    activity.reciever!.imageUrl,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ] else if (activity.isPinned)
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.push_pin_outlined),
              ),
          ],
        ),
        const SizedBox(height: 5),
        body,
      ],
    );
  }
}

class _ActivityMediaBox extends StatelessWidget {
  const _ActivityMediaBox(this.activityMedia, this.text);

  final ActivityMedia activityMedia;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      id: activityMedia.id,
      text: activityMedia.imageUrl,
      explorable: activityMedia.isAnime ? Explorable.anime : Explorable.manga,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Consts.borderRadiusMin,
              child: FadeImage(activityMedia.imageUrl, width: 70),
            ),
            Expanded(
              child: Padding(
                padding: Consts.padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.fade,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: text,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextSpan(
                              text: activityMedia.title,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (activityMedia.format != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        activityMedia.format!,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityFooter extends StatefulWidget {
  const ActivityFooter({
    required this.activity,
    required this.onDeleted,
    required this.onPinned,
    required this.onChanged,
    required this.onOpenReplies,
  });

  final Activity activity;
  final void Function() onDeleted;
  final void Function()? onPinned;
  final void Function()? onChanged;
  final void Function()? onOpenReplies;

  @override
  State<ActivityFooter> createState() => _ActivityFooterState();
}

class _ActivityFooterState extends State<ActivityFooter> {
  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return Row(
      children: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(maxHeight: Consts.iconSmall),
          splashColor: Colors.transparent,
          tooltip: 'More',
          icon: const Icon(
            Ionicons.ellipsis_horizontal,
            size: Consts.iconSmall,
          ),
          onPressed: _showMoreSheet,
        ),
        Tooltip(
          message: 'Replies',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onOpenReplies,
            child: Row(
              children: [
                Text(
                  activity.replyCount.toString(),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                const SizedBox(width: 5),
                const Icon(Ionicons.chatbox, size: Consts.iconSmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: !activity.isLiked ? 'Like' : 'Unlike',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleLike,
            child: Row(
              children: [
                Text(
                  activity.likeCount.toString(),
                  style: !activity.isLiked
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
                  color: activity.isLiked
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleLike() {
    final activity = widget.activity;
    final isLiked = activity.isLiked;

    setState(() {
      activity.isLiked = !isLiked;
      activity.likeCount += isLiked ? -1 : 1;
    });

    toggleActivityLike(activity).then(
      (ok) => ok
          ? widget.onChanged?.call()
          : setState(() {
              activity.isLiked = isLiked;
              activity.likeCount += isLiked ? 1 : -1;
            }),
    );
  }

  /// Show a sheet with additional options.
  void _showMoreSheet() {
    final activity = widget.activity;

    showSheet(
      context,
      Consumer(
        builder: (_, ref, __) =>
            FixedGradientDragSheet.link(context, activity.siteUrl!, [
          if (activity.isDeletable)
            FixedGradientSheetTile(
              text: 'Delete',
              icon: Ionicons.trash_outline,
              onTap: () => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Delete?',
                  mainAction: 'Yes',
                  secondaryAction: 'No',
                  onConfirm: () =>
                      deleteActivity(widget.activity.id).then((ok) {
                    if (ok) widget.onDeleted();
                  }),
                ),
              ),
            ),
          if (widget.onPinned != null && activity.type != ActivityType.MESSAGE)
            FixedGradientSheetTile(
              text: activity.isPinned ? 'Unpin' : 'Pin',
              icon:
                  activity.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              onTap: () {
                final isPinned = activity.isPinned;
                activity.isPinned = !isPinned;

                toggleActivityPin(activity).then((error) {
                  if (error == null) {
                    widget.onPinned!();
                    return;
                  }

                  activity.isPinned = isPinned;
                  showPopUp(
                    context,
                    ConfirmationDialog(
                      title: 'Could not toggle pin',
                      content: error.toString(),
                    ),
                  );
                });
              },
            ),
          FixedGradientSheetTile(
            text: !activity.isSubscribed ? 'Subscribe' : 'Unsubscribe',
            icon: !activity.isSubscribed
                ? Ionicons.notifications_outline
                : Ionicons.notifications_off_outline,
            onTap: () {
              final isSubscribed = activity.isSubscribed;
              activity.isSubscribed = !isSubscribed;

              toggleActivitySubscription(activity).then((ok) {
                ok
                    ? widget.onChanged?.call()
                    : activity.isSubscribed = isSubscribed;
              });
            },
          ),
        ]),
      ),
    );
  }
}

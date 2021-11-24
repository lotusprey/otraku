import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/activity_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/utils/navigation.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/constants/activity_type.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityBox extends StatelessWidget {
  final FeedController feed;
  final ActivityModel model;

  ActivityBox({required this.feed, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: ExploreIndexer(
                id: model.agentId,
                imageUrl: model.agentImage,
                explorable: Explorable.user,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: Config.BORDER_RADIUS,
                      child: FadeImage(model.agentImage, height: 50, width: 50),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        model.agentName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (model.recieverId != null) ...[
              if (model.isPrivate)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Ionicons.eye_off_outline),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_right_alt),
              ),
              ExploreIndexer(
                id: model.recieverId!,
                imageUrl: model.recieverImage,
                explorable: Explorable.user,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: FadeImage(model.recieverImage!, height: 50, width: 50),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        ActivityBoxBody(
          model,
          InteractionButtons(
            model: model,
            delete: () => feed.deleteActivity(model.id),
            toggleLike: () async {
              await ActivityController.toggleLike(model).then(
                (ok) => ok ? feed.updateActivity(model) : model.toggleLike(),
              );
            },
            toggleSubscribtion: () {
              ActivityController.toggleSubscription(model).then(
                (ok) => ok
                    ? feed.updateActivity(model)
                    : model.toggleSubscription(),
              );
            },
            pushActivityPage: () => Navigation().push(
              Navigation.activityRoute,
              args: [
                model.id,
                feed.id?.toString() ?? FeedController.HOME_FEED_TAG,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityBoxBody extends StatelessWidget {
  final ActivityModel model;
  final Widget interactions;
  ActivityBoxBody(this.model, this.interactions);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: Config.PADDING,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        children: [
          if (model.type == ActivityType.ANIME_LIST ||
              model.type == ActivityType.MANGA_LIST)
            ActivityBoxBodyMedia(model)
          else
            UnconstrainedBox(
              constrainedAxis: Axis.horizontal,
              alignment: Alignment.topLeft,
              child: HtmlContent(model.text),
            ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model.createdAt,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              interactions,
            ],
          ),
        ],
      ),
    );
  }
}

class InteractionButtons extends StatefulWidget {
  final ActivityModel model;
  final void Function() delete;
  final void Function() toggleSubscribtion;

  // setState(() {}) is called after the future is resolved, in case the
  // toggling was unsuccessful.
  final Future<void> Function() toggleLike;

  // If the user is on a feed page, this should open an activity page. If the
  // user is on an activity page, this should be null.
  final void Function()? pushActivityPage;

  InteractionButtons({
    required this.model,
    required this.delete,
    required this.toggleLike,
    required this.toggleSubscribtion,
    this.pushActivityPage,
  });

  @override
  _InteractionButtonsState createState() => _InteractionButtonsState();
}

class _InteractionButtonsState extends State<InteractionButtons> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return Row(
      children: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(maxHeight: Theming.ICON_SMALL),
          splashColor: Colors.transparent,
          tooltip: 'More',
          icon: const Icon(
            Ionicons.ellipsis_horizontal,
            size: Theming.ICON_SMALL,
          ),
          onPressed: () {
            final children = <Widget>[];
            if (model.deletable)
              children.add(DragSheetListTile(
                text: 'Delete',
                icon: Ionicons.trash_outline,
                onTap: () => showPopUp(
                  context,
                  ConfirmationDialog(
                    title: 'Delete?',
                    mainAction: 'Yes',
                    secondaryAction: 'No',
                    onConfirm: () {
                      widget.delete();

                      // If an activityPage cannot be pushed, it's
                      // already opened and should be closed.
                      if (widget.pushActivityPage == null)
                        Navigator.pop(context);
                    },
                  ),
                ),
              ));
            children.add(DragSheetListTile(
              text: !model.isSubscribed ? 'Subscribe' : 'Unsubscribe',
              icon: !model.isSubscribed
                  ? Ionicons.notifications_outline
                  : Ionicons.notifications_off_outline,
              onTap: () {
                model.toggleSubscription();
                widget.toggleSubscribtion();
              },
            ));
            children.add(DragSheetListTile(
              text: 'Copy Link',
              icon: Ionicons.clipboard_outline,
              onTap: () {
                if (model.siteUrl == null) {
                  Toast.show(context, 'Url is null');
                  return;
                }

                Toast.copy(context, model.siteUrl!);
              },
            ));
            children.add(DragSheetListTile(
              text: 'Open in Browser',
              icon: Ionicons.link_outline,
              onTap: () {
                if (model.siteUrl == null) {
                  Toast.show(context, 'Url is null');
                  return;
                }

                try {
                  launch(model.siteUrl!);
                } catch (err) {
                  Toast.show(context, 'Couldn\'t open link: $err');
                }
              },
            ));

            DragSheet.show(
              context,
              DragSheet(ctx: context, children: children),
            );
          },
        ),
        Tooltip(
          message: 'Replies',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.pushActivityPage,
            child: Row(
              children: [
                Text(
                  widget.model.replyCount.toString(),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                const SizedBox(width: 5),
                const Icon(Ionicons.chatbox, size: Theming.ICON_SMALL),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: !widget.model.isLiked ? 'Like' : 'Unlike',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => widget.model.toggleLike());
              widget.toggleLike().then((_) => setState(() {}));
            },
            child: Row(
              children: [
                Text(
                  widget.model.likeCount.toString(),
                  style: !widget.model.isLiked
                      ? Theme.of(context).textTheme.subtitle2
                      : Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.favorite,
                  size: Theming.ICON_SMALL,
                  color: widget.model.isLiked
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
}

class ActivityBoxBodyMedia extends StatelessWidget {
  final ActivityModel activity;
  ActivityBoxBodyMedia(this.activity);

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      id: activity.mediaId!,
      imageUrl: activity.mediaImage,
      explorable: activity.mediaType!,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Config.BORDER_RADIUS,
              child: FadeImage(activity.mediaImage!, width: 70),
            ),
            Expanded(
              child: Padding(
                padding: Config.PADDING,
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
                              text: activity.text,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextSpan(
                              text: activity.mediaTitle,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (activity.mediaFormat != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        activity.mediaFormat!,
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

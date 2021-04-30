import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/pages/activity_page.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/triangle_clip.dart';

class UserActivity extends StatelessWidget {
  final ActivityModel activity;

  UserActivity(this.activity);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BrowseIndexer(
              id: activity.agentId!,
              imageUrl: activity.agentImage,
              browsable: Browsable.user,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: Config.BORDER_RADIUS,
                    child: FadeImage(
                      activity.agentImage,
                      height: 50,
                      width: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    activity.agentName!,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
            if (activity.recieverId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_right_alt),
              ),
              BrowseIndexer(
                id: activity.recieverId!,
                imageUrl: activity.recieverImage,
                browsable: Browsable.user,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: FadeImage(
                    activity.recieverImage,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        ClipPath(
          clipper: TriangleClip(),
          child: Container(
            width: 50,
            height: 10,
            color: Theme.of(context).primaryColor,
          ),
        ),
        ActivityBox(activity),
      ],
    );
  }
}

class ActivityBox extends StatelessWidget {
  final ActivityModel activity;
  final bool canPushPage;

  ActivityBox(this.activity, {this.canPushPage = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: Config.PADDING,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        children: [
          if (activity.type == ActivityType.ANIME_LIST ||
              activity.type == ActivityType.MANGA_LIST)
            _MediaBox(activity)
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
              Text(
                activity.createdAt,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              _InteractionButtons(activity, canPushPage),
            ],
          ),
        ],
      ),
    );
  }
}

class _InteractionButtons extends StatefulWidget {
  final ActivityModel activity;
  final bool canPushPage;
  _InteractionButtons(this.activity, this.canPushPage);

  @override
  __InteractionButtonsState createState() => __InteractionButtonsState();
}

class __InteractionButtonsState extends State<_InteractionButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: !widget.activity.isSubscribed ? 'Subscribe' : 'Unsubscribe',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => widget.activity.toggleSubscription());
              Activity.toggleSubscription(widget.activity).then((ok) {
                if (!ok) setState(() => widget.activity.toggleSubscription());
              });
            },
            child: Icon(
              Ionicons.notifications,
              size: Style.ICON_SMALL,
              color: !widget.activity.isSubscribed
                  ? null
                  : Theme.of(context).accentColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Replies',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (widget.canPushPage)
                Get.toNamed(
                  ActivityPage.ROUTE,
                  arguments: [
                    widget.activity.id,
                    widget.activity,
                    (ActivityModel other) => setState(
                          () => widget.activity.updateFrom(other),
                        ),
                  ],
                  parameters: {'id': widget.activity.id.toString()},
                );
            },
            child: Row(
              children: [
                Text(
                  widget.activity.replyCount.toString(),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                const SizedBox(width: 5),
                const Icon(
                  Ionicons.chatbox,
                  size: Style.ICON_SMALL,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: !widget.activity.isLiked ? 'Like' : 'Unlike',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => widget.activity.toggleLike());
              Activity.toggleLike(widget.activity).then((ok) {
                if (!ok) setState(() => widget.activity.toggleLike());
              });
            },
            child: Row(
              children: [
                Text(
                  widget.activity.likeCount.toString(),
                  style: !widget.activity.isLiked
                      ? Theme.of(context).textTheme.subtitle2
                      : Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Theme.of(context).errorColor),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.favorite,
                  size: Style.ICON_SMALL,
                  color: widget.activity.isLiked
                      ? Theme.of(context).errorColor
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

class _MediaBox extends StatelessWidget {
  final ActivityModel activity;
  _MediaBox(this.activity);

  @override
  Widget build(BuildContext context) {
    return BrowseIndexer(
      id: activity.mediaId!,
      imageUrl: activity.mediaImage,
      browsable: activity.mediaType!,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Config.BORDER_RADIUS,
              child: FadeImage(activity.mediaImage, width: 70),
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
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            TextSpan(
                              text: activity.mediaTitle,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (activity.mediaFormat != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          activity.mediaFormat!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
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

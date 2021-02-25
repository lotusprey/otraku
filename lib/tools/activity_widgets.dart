import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/anilist/activity_model.dart';
import 'package:otraku/pages/pushable/activity_page.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/html_content.dart';
import 'package:otraku/tools/triangle_clip.dart';

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
              id: activity.agentId,
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
                    activity.agentName,
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
                id: activity.recieverId,
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
  final bool canNavigateToReplies;

  ActivityBox(this.activity, [this.canNavigateToReplies = true]);

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
            BrowseIndexer(
              id: activity.mediaId,
              imageUrl: activity.mediaImage,
              browsable: activity.mediaType,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 108),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: Config.BORDER_RADIUS,
                      child: FadeImage(
                        activity.mediaImage,
                        width: 70,
                      ),
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
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    TextSpan(
                                      text: activity.mediaTitle,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                activity.mediaFormat,
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
            )
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
              Row(
                children: [
                  _SubscribeIcon(activity),
                  const SizedBox(width: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (canNavigateToReplies)
                        Get.toNamed(
                          ActivityPage.ROUTE,
                          arguments: [activity.id, activity],
                          parameters: {'id': activity.id.toString()},
                        );
                    },
                    child: Row(
                      children: [
                        Text(
                          activity.replyCount.toString(),
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.comment,
                          size: Styles.ICON_SMALLER,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ActivityLikeIcon(activity),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityLikeIcon extends StatefulWidget {
  final ActivityModel activity;
  _ActivityLikeIcon(this.activity);

  @override
  _ActivityLikeIconState createState() => _ActivityLikeIconState();
}

class _ActivityLikeIconState extends State<_ActivityLikeIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Activity.toggleActivityLike(widget.activity)
          .then((_) => setState(() {})),
      child: Row(
        children: [
          Text(
            widget.activity.likeCount.toString(),
            style: !widget.activity.isLiked
                ? Theme.of(context).textTheme.subtitle2
                : Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Theme.of(context).errorColor),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.favorite,
            size: Styles.ICON_SMALLER,
            color:
                widget.activity.isLiked ? Theme.of(context).errorColor : null,
          ),
        ],
      ),
    );
  }
}

class _SubscribeIcon extends StatefulWidget {
  final ActivityModel activity;
  _SubscribeIcon(this.activity);

  @override
  _SubscribeIconState createState() => _SubscribeIconState();
}

class _SubscribeIconState extends State<_SubscribeIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Activity.toggleSubscription(widget.activity)
          .then((_) => setState(() {})),
      child: !(widget.activity.isSubscribed ?? false)
          ? Icon(
              Icons.notifications,
              size: Styles.ICON_SMALLER,
            )
          : Icon(
              Icons.notifications_active,
              size: Styles.ICON_SMALLER,
              color: Theme.of(context).accentColor,
            ),
    );
  }
}

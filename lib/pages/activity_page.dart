import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/reply_model.dart';
import 'package:otraku/widgets/activity_widgets.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/triangle_clip.dart';

class ActivityPage extends StatelessWidget {
  static const ROUTE = '/activity';

  final int id;

  ActivityPage(this.id);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Activity>(
        tag: id.toString(),
        builder: (activity) {
          final model = activity.model;
          return Scaffold(
            appBar: CustomAppBar(
              titleWidget: model != null
                  ? Row(
                      children: [
                        Flexible(
                          child: BrowseIndexer(
                            id: model.agentId!,
                            imageUrl: model.agentImage,
                            browsable: Browsable.user,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Hero(
                                  tag: model.agentId!,
                                  child: ClipRRect(
                                    borderRadius: Config.BORDER_RADIUS,
                                    child: FadeImage(
                                      model.agentImage,
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    model.agentName!,
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
                          BrowseIndexer(
                            id: model.recieverId!,
                            imageUrl: model.recieverImage,
                            browsable: Browsable.user,
                            child: ClipRRect(
                              borderRadius: Config.BORDER_RADIUS,
                              child: FadeImage(
                                model.recieverImage,
                                height: 40,
                                width: 40,
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : null,
            ),
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: Config.PHYSICS,
                controller: activity.scrollCtrl,
                slivers: [
                  if (model != null) ...[
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: Config.PADDING,
                      child: _ActivityBox(activity),
                    )),
                    SliverPadding(
                      padding: Config.PADDING,
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _UserReply(model.replies.items[i]),
                          childCount: model.replies.items.length,
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: Obx(
                        () => Center(
                          child: activity.isLoading ? Loader() : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class _ActivityBox extends StatelessWidget {
  final Activity activity;
  _ActivityBox(this.activity);

  @override
  Widget build(BuildContext context) {
    final model = activity.model!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: Config.PADDING,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        children: [
          if (model.type == ActivityType.ANIME_LIST ||
              model.type == ActivityType.MANGA_LIST)
            MediaBox(model)
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
              _InteractionButtons(activity),
            ],
          ),
        ],
      ),
    );
  }
}

class _InteractionButtons extends StatefulWidget {
  final Activity activity;
  _InteractionButtons(this.activity);
  @override
  __InteractionButtonsState createState() => __InteractionButtonsState();
}

class __InteractionButtonsState extends State<_InteractionButtons> {
  @override
  Widget build(BuildContext context) {
    final model = widget.activity.model!;

    return Row(
      children: [
        if (model.deletable)
          Tooltip(
            message: 'Delete',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: const Icon(Ionicons.trash, size: Style.ICON_SMALL),
              onTap: () => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Delete?',
                  mainAction: 'Yes',
                  secondaryAction: 'No',
                  onConfirm: () {
                    widget.activity.deleteModel();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Tooltip(
          message: !model.isSubscribed ? 'Subscribe' : 'Unsubscribe',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => model.toggleSubscription());
              Activity.toggleSubscription(model).then(
                (ok) => ok
                    ? widget.activity.updateModel()
                    : setState(() => model.toggleSubscription()),
              );
            },
            child: Icon(
              Ionicons.notifications,
              size: Style.ICON_SMALL,
              color: !model.isSubscribed ? null : Theme.of(context).accentColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Replies',
          child: Row(
            children: [
              Text(
                model.replyCount.toString(),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              const SizedBox(width: 5),
              const Icon(Ionicons.chatbox, size: Style.ICON_SMALL),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: !model.isLiked ? 'Like' : 'Unlike',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => model.toggleLike());
              Activity.toggleLike(model).then(
                (ok) => ok
                    ? widget.activity.updateModel()
                    : setState(() => model.toggleLike()),
              );
            },
            child: Row(
              children: [
                Text(
                  model.likeCount.toString(),
                  style: !model.isLiked
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
                  color: model.isLiked ? Theme.of(context).errorColor : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UserReply extends StatelessWidget {
  final ReplyModel reply;

  _UserReply(this.reply);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrowseIndexer(
          id: reply.userId,
          imageUrl: reply.userImage,
          browsable: Browsable.user,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: Config.BORDER_RADIUS,
                child: FadeImage(
                  reply.userImage,
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(width: 10),
              Text(reply.userName),
            ],
          ),
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
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: Config.PADDING,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: Config.BORDER_RADIUS,
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
                  _ReplyLikeIcon(reply),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyLikeIcon extends StatefulWidget {
  final ReplyModel reply;
  _ReplyLikeIcon(this.reply);

  @override
  _ReplyLikeIconState createState() => _ReplyLikeIconState();
}

class _ReplyLikeIconState extends State<_ReplyLikeIcon> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: !widget.reply.isLiked ? 'Like' : 'Unlike',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => widget.reply.toggleLike());
          Activity.toggleReplyLike(widget.reply).then((ok) {
            if (!ok) setState(() => widget.reply.toggleLike());
          });
        },
        child: Row(
          children: [
            Text(
              widget.reply.likeCount.toString(),
              style: !widget.reply.isLiked
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
              color: widget.reply.isLiked ? Theme.of(context).errorColor : null,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/reply_model.dart';
import 'package:otraku/widgets/activity_widgets.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/loader.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
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
                        BrowseIndexer(
                          id: model.agentId,
                          imageUrl: model.agentImage,
                          browsable: Browsable.user,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Hero(
                                tag: model.agentId,
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
                              Text(
                                model.agentName,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                        ),
                        if (model.recieverId != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.arrow_right_alt),
                          ),
                          BrowseIndexer(
                            id: model.recieverId,
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
                slivers: [
                  if (model != null) ...[
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: ActivityBox(model, false),
                    )),
                    SliverPadding(
                      padding: const EdgeInsets.all(10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            if (i == model.replies.items.length - 5)
                              activity.fetchPage();
                            return UserReply(model.replies.items[i]);
                          },
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

class UserReply extends StatelessWidget {
  final ReplyModel reply;

  UserReply(this.reply);

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
              Text(
                reply.userName,
                style: Theme.of(context).textTheme.bodyText1,
              ),
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
        onTap: () =>
            Activity.toggleReplyLike(widget.reply).then((_) => setState(() {})),
        child: Row(
          children: [
            Text(
              widget.reply.likeCount.toString(),
              style: !widget.reply.isLiked
                  ? Theme.of(context).textTheme.subtitle2
                  : Theme.of(context)
                      .textTheme
                      .subtitle2
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

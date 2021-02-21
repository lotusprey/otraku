import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/anilist/reply_model.dart';
import 'package:otraku/tools/activity_widgets.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/html_content.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';
import 'package:otraku/tools/triangle_clip.dart';

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
              child: model != null
                  ? ListView.builder(
                      physics: Config.PHYSICS,
                      padding: Config.PADDING,
                      itemBuilder: (_, i) => i > 0
                          ? UserReply(model.replies.items[i - 1])
                          : ActivityBox(model),
                      itemCount: model.replies.items.length + 1,
                    )
                  : Center(child: Loader()),
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
    return GestureDetector(
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
            size: Styles.ICON_SMALLER,
            color: widget.reply.isLiked ? Theme.of(context).errorColor : null,
          ),
        ],
      ),
    );
  }
}

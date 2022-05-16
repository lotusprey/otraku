import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/activity_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/reply_model.dart';
import 'package:otraku/widgets/activity_box.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class ActivityView extends StatelessWidget {
  final int id;
  final String? feedTag;

  ActivityView(this.id, this.feedTag);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivityController>(
        init: ActivityController(id, feedTag),
        tag: id.toString(),
        builder: (ctrl) {
          final model = ctrl.model;
          return Scaffold(
            appBar: ShadowAppBar(
              titleWidget: model != null
                  ? Row(
                      children: [
                        Flexible(
                          child: ExploreIndexer(
                            id: model.agentId,
                            imageUrl: model.agentImage,
                            explorable: Explorable.user,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Hero(
                                  tag: model.agentId,
                                  child: ClipRRect(
                                    borderRadius: Consts.borderRadiusMin,
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
                              borderRadius: Consts.borderRadiusMin,
                              child: FadeImage(
                                model.recieverImage!,
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
                physics: Consts.physics,
                controller: ctrl.scrollCtrl,
                slivers: [
                  if (model != null) ...[
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: Consts.padding,
                      child: ActivityBoxBody(
                        model,
                        InteractionButtons(
                          model: model,
                          delete: ctrl.deleteModel,
                          toggleLike: () async =>
                              await ActivityController.toggleLike(model).then(
                            (ok) =>
                                ok ? ctrl.updateModel() : model.toggleLike(),
                          ),
                          toggleSubscribtion: () =>
                              ActivityController.toggleSubscription(model).then(
                            (ok) => ok
                                ? ctrl.updateModel()
                                : model.toggleSubscription(),
                          ),
                        ),
                      ),
                    )),
                    SliverPadding(
                      padding: Consts.padding,
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
                      child: GetBuilder<ActivityController>(
                        id: ActivityController.ID_LOADING,
                        tag: id.toString(),
                        builder: (ctrl) => Center(
                          child: ctrl.isLoading ? const Loader() : null,
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

class _UserReply extends StatelessWidget {
  final ReplyModel reply;

  _UserReply(this.reply);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExploreIndexer(
          id: reply.userId,
          imageUrl: reply.userImage,
          explorable: Explorable.user,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: Consts.borderRadiusMin,
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
          ActivityController.toggleReplyLike(widget.reply).then((ok) {
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
}

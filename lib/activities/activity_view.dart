import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activities/activity.dart';
import 'package:otraku/activities/activity_card.dart';
import 'package:otraku/activities/reply_card.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView(this.id, this.onChanged);

  final int id;
  final void Function(Activity?)? onChanged;

  @override
  ConsumerState<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  late final PaginationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PaginationController(
      loadMore: () => ref.read(activityProvider(widget.id).notifier).fetch(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(
        activityProvider(widget.id).select((s) => s.valueOrNull?.activity));

    return PageLayout(
      topBar: TopBar(
        items: [
          if (activity != null)
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: ExploreIndexer(
                      id: activity.agent.id,
                      imageUrl: activity.agent.imageUrl,
                      explorable: Explorable.user,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: activity.agent.id,
                            child: ClipRRect(
                              borderRadius: Consts.borderRadiusMin,
                              child: FadeImage(
                                activity.agent.imageUrl,
                                height: 40,
                                width: 40,
                              ),
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
                      imageUrl: activity.reciever!.imageUrl,
                      explorable: Explorable.user,
                      child: ClipRRect(
                        borderRadius: Consts.borderRadiusMin,
                        child: FadeImage(
                          activity.reciever!.imageUrl,
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
      builder: (context, _, __) => Consumer(
        child: SliverRefreshControl(
          onRefresh: () {
            ref.invalidate(activityProvider(widget.id));
            return Future.value();
          },
        ),
        builder: (context, ref, refreshControl) {
          ref.listen<AsyncValue>(
            activityProvider(widget.id),
            (_, s) => s.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load activity',
                  content: error.toString(),
                ),
              ),
            ),
          );

          return ref
              .watch(activityProvider(widget.id))
              .unwrapPrevious()
              .maybeWhen(
                loading: () => const Center(child: Loader()),
                orElse: () => Center(child: Text('No Replies')),
                data: (data) {
                  return Padding(
                    padding: Consts.padding,
                    child: CustomScrollView(
                      physics: Consts.physics,
                      controller: _ctrl,
                      slivers: [
                        refreshControl!,
                        SliverToBoxAdapter(
                          child: ActivityCard(
                            withHeader: false,
                            activity: data.activity,
                            footer: ActivityFooter(
                              activity: data.activity,
                              canPush: false,
                              onChanged: (activity) {
                                widget.onChanged?.call(activity);
                                if (activity == null) Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: data.replies.items.length,
                            (context, i) => ReplyCard(data.replies.items[i]),
                          ),
                        ),
                        SliverFooter(loading: data.replies.hasNext),
                      ],
                    ),
                  );
                },
              );
        },
      ),
    );
  }
}

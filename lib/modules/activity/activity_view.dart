import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/modules/activity/activities_provider.dart';
import 'package:otraku/modules/activity/activity_models.dart';
import 'package:otraku/modules/activity/activity_provider.dart';
import 'package:otraku/modules/activity/activity_card.dart';
import 'package:otraku/modules/activity/reply_card.dart';
import 'package:otraku/modules/composition/composition_model.dart';
import 'package:otraku/modules/composition/composition_view.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/utils/persistence.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView(this.id, this.feedId);

  final int id;
  final int? feedId;

  @override
  ConsumerState<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  late final _ctrl = PagedController(
    loadMore: () => ref.read(activityProvider(widget.id).notifier).fetch(),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(
      activityProvider(widget.id).select((s) => s.valueOrNull?.activity),
    );

    return PageScaffold(
      child: TabScaffold(
        topBar: TopBar(
          trailing: [if (activity != null) _TopBarContent(activity)],
        ),
        floatingBar: FloatingBar(
          scrollCtrl: _ctrl,
          children: [
            ActionButton(
              tooltip: 'New Reply',
              icon: Icons.edit_outlined,
              onTap: () => showSheet(
                context,
                CompositionView(
                  tag: ActivityReplyCompositionTag(
                    id: null,
                    activityId: widget.id,
                  ),
                  onSaved: (map) => ref
                      .read(activityProvider(widget.id).notifier)
                      .appendReply(map),
                ),
              ),
            ),
          ],
        ),
        child: Consumer(
          child: SliverRefreshControl(
            onRefresh: () => ref.invalidate(activityProvider(widget.id)),
          ),
          builder: (context, ref, refreshControl) {
            ref.listen<AsyncValue>(
              activityProvider(widget.id),
              (_, s) => s.whenOrNull(
                error: (error, _) => showPopUp(
                  context,
                  ConfirmationDialog(
                    title: 'Failed to load activity',
                    content: error.toString(),
                  ),
                ),
              ),
            );

            return ref.watch(activityProvider(widget.id)).unwrapPrevious().when(
                  loading: () => const Center(child: Loader()),
                  error: (_, __) => const Center(
                    child: Text('Failed to load activity'),
                  ),
                  data: (data) {
                    return ConstrainedView(
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
                                onDeleted: () => _onDeleted(data.activity),
                                onChanged: () => _onChanged(data.activity),
                                onEdited: _onEdited,
                                onPinned: () => setState(() {}),
                                onOpenReplies: null,
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: data.replies.items.length,
                              (context, i) =>
                                  ReplyCard(widget.id, data.replies.items[i]),
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
      ),
    );
  }

  void _onDeleted(Activity activity) {
    if (widget.feedId != null) {
      ref.read(activitiesProvider(widget.feedId!).notifier).remove(widget.id);
    }
    Navigator.pop(context);
  }

  void _onChanged(Activity activity) {
    if (widget.feedId != null) {
      ref
          .read(activitiesProvider(widget.feedId!).notifier)
          .updateActivity(activity);
    }
  }

  void _onEdited(Map<String, dynamic> map) {
    final activity = ref
        .read(activityProvider(widget.id).notifier)
        .replaceActivity(map, Persistence().id!);
    if (activity != null && widget.feedId != null) {
      ref
          .read(activitiesProvider(widget.feedId!).notifier)
          .updateActivity(activity);
    }
  }
}

class _TopBarContent extends StatelessWidget {
  const _TopBarContent(this.activity);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            child: LinkTile(
              id: activity.authorId,
              info: activity.authorAvatarUrl,
              discoverType: DiscoverType.user,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: activity.authorId,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: CachedImage(
                        activity.authorAvatarUrl,
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      activity.authorName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...switch (activity) {
            MessageActivity message => [
                if (message.isPrivate)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Ionicons.eye_off_outline),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_right_alt),
                ),
                LinkTile(
                  id: message.recipientId,
                  info: message.recipientAvatarUrl,
                  discoverType: DiscoverType.user,
                  child: ClipRRect(
                    borderRadius: Consts.borderRadiusMin,
                    child: CachedImage(
                      message.recipientAvatarUrl,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ],
            _ when activity.isPinned => const [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.push_pin_outlined),
                ),
              ],
            _ => const [],
          },
        ],
      ),
    );
  }
}

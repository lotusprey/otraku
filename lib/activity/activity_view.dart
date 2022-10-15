import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activity_models.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/activity/activity_card.dart';
import 'package:otraku/activity/reply_card.dart';
import 'package:otraku/composition/composition_model.dart';
import 'package:otraku/composition/composition_view.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView(this.id, this.onChanged);

  final int id;
  final void Function(Activity?)? onChanged;

  @override
  ConsumerState<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  late final _ctrl = PaginationController(
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
        activityProvider(widget.id).select((s) => s.valueOrNull?.activity));

    return PageLayout(
      topBar: PreferredSize(
        preferredSize: const Size.fromHeight(Consts.tapTargetSize),
        child: activity == null ? const TopBar() : _TopBar(activity),
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
                composition: Composition.reply(null, '', widget.id),
                onDone: (map) => ref
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
                orElse: () => const Center(child: Text('No Activity')),
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
                              onChanged: () =>
                                  widget.onChanged?.call(data.activity),
                              onDeleted: () {
                                widget.onChanged?.call(null);
                                Navigator.pop(context);
                              },
                              onPinned: () => setState(() {}),
                              onOpenReplies: null,
                              onEdited: (map) {
                                ref
                                    .read(activityProvider(widget.id).notifier)
                                    .replaceActivity(map, Options().id!);
                              },
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
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar(this.activity);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return TopBar(
      items: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: LinkTile(
                  id: activity.agent.id,
                  info: activity.agent.imageUrl,
                  discoverType: DiscoverType.user,
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
                LinkTile(
                  id: activity.reciever!.id,
                  info: activity.reciever!.imageUrl,
                  discoverType: DiscoverType.user,
                  child: ClipRRect(
                    borderRadius: Consts.borderRadiusMin,
                    child: FadeImage(
                      activity.reciever!.imageUrl,
                      height: 40,
                      width: 40,
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
        ),
      ],
    );
  }
}

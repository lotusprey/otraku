import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/providers/activities.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ActivitiesView extends ConsumerStatefulWidget {
  const ActivitiesView(this.id);

  final int id;

  @override
  ConsumerState<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends ConsumerState<ActivitiesView> {
  late final PaginationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PaginationController(
      loadMore: () => ref.read(activitiesProvider(widget.id).notifier).fetch(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      topBar: const TopBar(title: 'Activities'),
      floatingBar: FloatingBar(
        scrollCtrl: _ctrl,
        child: ActionButton(
          tooltip: 'Filter',
          icon: Ionicons.funnel_outline,
          onTap: () {
            final typeIn = [...ref.read(activityFilterProvider(widget.id))];
            bool changed = false;

            final initialHeight =
                Consts.tapTargetSize * ActivityType.values.length + 20;

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: initialHeight,
                builder: (context, scrollCtrl) => ListView(
                  controller: scrollCtrl,
                  physics: Consts.physics,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      padding: Consts.padding,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final a in ActivityType.values)
                          CheckBoxField(
                            title: a.text,
                            initial: typeIn.contains(a),
                            onChanged: (val) {
                              val ? typeIn.add(a) : typeIn.remove(a);
                              changed = true;
                            },
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ).then((_) {
              if (!changed) return;
              ref
                  .read(activityFilterProvider(widget.id).notifier)
                  .update((_) => typeIn);
            });
          },
        ),
      ),
      builder: (context, topOffset, bottomOffset) => Consumer(
        child: SliverRefreshControl(
          onRefresh: () {
            ref.invalidate(activitiesProvider(widget.id));
            return Future.value();
          },
          topOffset: topOffset,
        ),
        builder: (context, ref, refreshIndicator) {
          ref.listen<AsyncValue>(
            activitiesProvider(widget.id),
            (_, s) => s.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load activities',
                  content: error.toString(),
                ),
              ),
            ),
          );

          const empty = Center(child: Text('No Activities'));

          return ref
              .watch(activitiesProvider(widget.id))
              .unwrapPrevious()
              .maybeWhen(
                loading: () => const Center(child: Loader()),
                orElse: () => empty,
                data: (data) {
                  if (data.items.isEmpty) return empty;

                  final delete = (id) => ref
                      .read(activitiesProvider(widget.id).notifier)
                      .delete(id);

                  final toggleLike = (id) => ref
                      .read(activitiesProvider(widget.id).notifier)
                      .toggleLike(id);

                  final toggleSubscription = (id, subscribe) => ref
                      .read(activitiesProvider(widget.id).notifier)
                      .toggleSubscription(id, subscribe);

                  return Padding(
                    padding: Consts.padding,
                    child: CustomScrollView(
                      physics: Consts.physics,
                      controller: _ctrl,
                      slivers: [
                        refreshIndicator!,
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: data.items.length,
                            (context, i) => _Activity(
                              data.items[i],
                              _Buttons(
                                activity: data.items[i],
                                delete: delete,
                                toggleLike: toggleLike,
                                toggleSubscription: toggleSubscription,
                              ),
                            ),
                          ),
                        ),
                        if (data.hasNext) const SliverFooterLoader(),
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

class _Activity extends StatelessWidget {
  const _Activity(this.activity, this.buttons);

  final Activity activity;
  final Widget buttons;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: ExploreIndexer(
                id: activity.agent.id,
                imageUrl: activity.agent.imageUrl,
                explorable: Explorable.user,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: FadeImage(
                        activity.agent.imageUrl,
                        height: 50,
                        width: 50,
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
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ],
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
              if (activity.media != null)
                _ActivityMediaBox(activity.media!, activity.text)
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
                  Flexible(
                    child: Text(
                      activity.createdAt,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  buttons,
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityMediaBox extends StatelessWidget {
  const _ActivityMediaBox(this.activityMedia, this.text);

  final ActivityMedia activityMedia;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      id: activityMedia.id,
      imageUrl: activityMedia.imageUrl,
      explorable: activityMedia.isAnime ? Explorable.anime : Explorable.manga,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Consts.borderRadiusMin,
              child: FadeImage(activityMedia.imageUrl, width: 70),
            ),
            Expanded(
              child: Padding(
                padding: Consts.padding,
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
                              text: text,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextSpan(
                              text: activityMedia.title,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (activityMedia.format != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        activityMedia.format!,
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

class _Buttons extends StatefulWidget {
  const _Buttons({
    required this.activity,
    required this.delete,
    required this.toggleLike,
    required this.toggleSubscription,
  });

  final Activity activity;

  /// Deletes the activity by its id.
  final Future<void> Function(int) delete;

  /// Toggles a like by the activity's id. Returns true if successful.
  final Future<bool> Function(int) toggleLike;

  /// Toggles a subscription by the activity's id and
  /// its subscription state. Returns true if successful.
  final Future<bool> Function(int, bool) toggleSubscription;

  @override
  State<_Buttons> createState() => __ButtonsState();
}

class __ButtonsState extends State<_Buttons> {
  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return Row(
      children: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(maxHeight: Consts.iconSmall),
          splashColor: Colors.transparent,
          tooltip: 'More',
          icon: const Icon(
            Ionicons.ellipsis_horizontal,
            size: Consts.iconSmall,
          ),
          onPressed: _showMoreSheet,
        ),
        Tooltip(
          message: 'Replies',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pushNamed(
              context,
              RouteArg.activity,
              arguments: RouteArg(id: activity.id),
            ),
            child: Row(
              children: [
                Text(
                  activity.replyCount.toString(),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                const SizedBox(width: 5),
                const Icon(Ionicons.chatbox, size: Consts.iconSmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: !activity.isLiked ? 'Like' : 'Unlike',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleLike,
            child: Row(
              children: [
                Text(
                  activity.likeCount.toString(),
                  style: !activity.isLiked
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
                  color: activity.isLiked
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

  /// Toggle a like and revert the change,
  /// if the reqest was unsuccessful.
  void _toggleLike() {
    final activity = widget.activity;
    final isLiked = activity.isLiked;

    setState(() {
      activity.isLiked = !isLiked;
      activity.likeCount += isLiked ? -1 : 1;
    });

    widget.toggleLike(activity.id).then((ok) {
      if (ok) return;
      setState(() {
        activity.isLiked = isLiked;
        activity.likeCount += isLiked ? 1 : -1;
      });
    });
  }

  /// Show a sheet with additional options.
  void _showMoreSheet() {
    final activity = widget.activity;
    final children = <Widget>[];

    /// Delete the activity.
    if (activity.isDeletable)
      children.add(FixedGradientSheetTile(
        text: 'Delete',
        icon: Ionicons.trash_outline,
        onTap: () => showPopUp(
          context,
          ConfirmationDialog(
            title: 'Delete?',
            mainAction: 'Yes',
            secondaryAction: 'No',
            onConfirm: () => widget.delete(activity.id),
          ),
        ),
      ));

    /// Toggle a subscription and revert the change,
    /// if the reqest was unsuccessful.
    children.add(FixedGradientSheetTile(
      text: !activity.isSubscribed ? 'Subscribe' : 'Unsubscribe',
      icon: !activity.isSubscribed
          ? Ionicons.notifications_outline
          : Ionicons.notifications_off_outline,
      onTap: () {
        final isSubscribed = activity.isSubscribed;
        activity.isSubscribed = !isSubscribed;

        widget.toggleSubscription(activity.id, !isSubscribed).then((ok) {
          if (!ok) activity.isSubscribed = isSubscribed;
        });
      },
    ));

    showSheet(
      context,
      FixedGradientDragSheet.link(context, activity.siteUrl!, children),
    );
  }
}

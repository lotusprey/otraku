import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/activity/activity_card.dart';
import 'package:otraku/composition/composition_model.dart';
import 'package:otraku/composition/composition_view.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/activity/activity_models.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/layouts/segment_switcher.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

void showActivityFilterSheet(BuildContext context, WidgetRef ref, int? id) {
  final filter = ref.read(activityFilterProvider(id));
  final typeIn = [...filter.typeIn];
  bool? onFollowing = filter.onFollowing;
  bool changed = false;

  double initialHeight = Consts.tapTargetSize * ActivityType.values.length + 20;
  if (onFollowing != null) initialHeight += Consts.tapTargetSize;

  showSheet(
    context,
    OpaqueSheet(
      initialHeight: initialHeight,
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        physics: Consts.physics,
        padding: Consts.padding,
        children: [
          ListView(
            shrinkWrap: true,
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
          if (onFollowing != null)
            CompactSegmentSwitcher(
              items: const ['Following', 'Global'],
              current: onFollowing! ? 0 : 1,
              onChanged: (val) {
                onFollowing = val == 0;
                changed = true;
              },
            ),
        ],
      ),
    ),
  ).then((_) {
    if (changed)
      ref.read(activityFilterProvider(id).notifier).update(typeIn, onFollowing);
  });
}

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
        children: [
          ActionButton(
            tooltip: widget.id == Settings().id ? 'New Post' : 'New Message',
            icon: Icons.edit_outlined,
            onTap: () => showSheet(
              context,
              CompositionView(
                composition: widget.id == Settings().id
                    ? Composition.status(null, '')
                    : Composition.message(null, '', widget.id),
                onDone: (map) => ref
                    .read(activitiesProvider(widget.id).notifier)
                    .insertActivity(map, Settings().id!),
              ),
            ),
          ),
          ActionButton(
            tooltip: 'Filter',
            icon: Ionicons.funnel_outline,
            onTap: () => showActivityFilterSheet(context, ref, widget.id),
          ),
        ],
      ),
      child: ActivitiesSubView(widget.id, _ctrl),
    );
  }
}

class ActivitiesSubView extends StatelessWidget {
  const ActivitiesSubView(this.id, this.ctrl);

  final int? id;
  final ScrollController ctrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          activitiesProvider(id),
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

        return ref.watch(activitiesProvider(id)).unwrapPrevious().when(
              loading: () => const Center(child: Loader()),
              error: (_, __) => empty,
              data: (data) {
                if (data.items.isEmpty) return empty;

                return Padding(
                  padding: Consts.padding,
                  child: CustomScrollView(
                    physics: Consts.physics,
                    controller: ctrl,
                    slivers: [
                      SliverRefreshControl(
                        onRefresh: () {
                          ref.invalidate(activitiesProvider(id));
                          return Future.value();
                        },
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: data.items.length,
                          (context, i) => ActivityCard(
                            withHeader: true,
                            activity: data.items[i],
                            footer: ActivityFooter(
                              activity: data.items[i],
                              onDeleted: () => ref
                                  .read(activitiesProvider(id).notifier)
                                  .remove(data.items[i].id),
                              onChanged: null,
                              onPinned: id == Settings().id
                                  ? () => ref
                                      .read(activitiesProvider(id).notifier)
                                      .togglePin(data.items[i].id)
                                  : null,
                              onOpenReplies: () => Navigator.pushNamed(
                                context,
                                RouteArg.activity,
                                arguments: RouteArg(
                                  id: data.items[i].id,
                                  callback: (arg) {
                                    final updatedActivity = arg as Activity?;
                                    if (updatedActivity == null) {
                                      ref
                                          .read(activitiesProvider(id).notifier)
                                          .remove(data.items[i].id);
                                      return;
                                    }

                                    ref
                                        .read(activitiesProvider(id).notifier)
                                        .updateActivity(updatedActivity);
                                  },
                                ),
                              ),
                              onEdited: (map) {
                                ref
                                    .read(activitiesProvider(id).notifier)
                                    .replaceActivity(map);
                              },
                            ),
                          ),
                        ),
                      ),
                      SliverFooter(loading: data.hasNext),
                    ],
                  ),
                );
              },
            );
      },
    );
  }
}

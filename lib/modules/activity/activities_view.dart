import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/activity/activity_filter_sheet.dart';
import 'package:otraku/modules/activity/activities_providers.dart';
import 'package:otraku/modules/activity/activity_card.dart';
import 'package:otraku/modules/composition/composition_model.dart';
import 'package:otraku/modules/composition/composition_view.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/modules/activity/activity_models.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/utils/route_arg.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/paged_view.dart';

class ActivitiesView extends ConsumerStatefulWidget {
  const ActivitiesView(this.id);

  final int id;

  @override
  ConsumerState<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends ConsumerState<ActivitiesView> {
  late final _ctrl = PagedController(
    loadMore: () => ref.read(activitiesProvider(widget.id).notifier).fetch(),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: TabScaffold(
        topBar: const TopBar(title: 'Activities'),
        floatingBar: FloatingBar(
          scrollCtrl: _ctrl,
          children: [
            ActionButton(
              tooltip: widget.id == Options().id ? 'New Post' : 'New Message',
              icon: Icons.edit_outlined,
              onTap: () => showSheet(
                context,
                CompositionView(
                  composition: widget.id == Options().id
                      ? Composition.status(null, '')
                      : Composition.message(null, '', widget.id),
                  onDone: (map) => ref
                      .read(activitiesProvider(widget.id).notifier)
                      .insertActivity(map, Options().id!),
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
      ),
    );
  }
}

class ActivitiesSubView extends StatelessWidget {
  const ActivitiesSubView(this.id, this.scrollCtrl);

  final int? id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return PagedView<Activity>(
          provider: activitiesProvider(id),
          scrollCtrl: scrollCtrl,
          onRefresh: () {
            ref.invalidate(activitiesProvider(id));
            if (id == null) {
              ref.read(settingsProvider.notifier).refetchUnread();
            }
          },
          onData: (data) => SliverList(
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
                  onPinned: id == Options().id
                      ? () => ref
                          .read(activitiesProvider(id).notifier)
                          .togglePin(data.items[i].id)
                      : null,
                  onOpenReplies: () =>
                      _onOpenReplies(context, ref, data.items[i]),
                  onEdited: (map) {
                    ref
                        .read(activitiesProvider(id).notifier)
                        .replaceActivity(map);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onOpenReplies(BuildContext context, WidgetRef ref, Activity activity) {
    Navigator.pushNamed(
      context,
      RouteArg.activity,
      arguments: RouteArg(
        id: activity.id,
        callback: (arg) {
          final updatedActivity = arg as Activity?;
          if (updatedActivity == null) {
            ref.read(activitiesProvider(id).notifier).remove(activity.id);
            return;
          }

          ref
              .read(activitiesProvider(id).notifier)
              .updateActivity(updatedActivity);
        },
      ),
    );
  }
}

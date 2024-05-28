import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/routing.dart';
import 'package:otraku/feature/activity/activity_filter_sheet.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activity_card.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/widget/paged_view.dart';

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
              tooltip:
                  widget.id == Persistence().id ? 'New Post' : 'New Message',
              icon: Icons.edit_outlined,
              onTap: () => showSheet(
                context,
                CompositionView(
                  tag: widget.id == Persistence().id
                      ? const StatusActivityCompositionTag(id: null)
                      : MessageActivityCompositionTag(
                          id: null,
                          recipientId: widget.id,
                        ),
                  onSaved: (map) => ref
                      .read(activitiesProvider(widget.id).notifier)
                      .prepend(map),
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

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return PagedView<Activity>(
          provider: activitiesProvider(id).select(
            (s) => s.unwrapPrevious().whenData((data) => data),
          ),
          scrollCtrl: scrollCtrl,
          onRefresh: (invalidate) {
            invalidate(activitiesProvider(id));
            if (id == homeFeedId) {
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
                  toggleLike: () => ref
                      .read(activitiesProvider(id).notifier)
                      .toggleLike(data.items[i]),
                  toggleSubscription: () => ref
                      .read(activitiesProvider(id).notifier)
                      .toggleSubscription(data.items[i]),
                  togglePin: id == Persistence().id
                      ? () => ref
                          .read(activitiesProvider(id).notifier)
                          .togglePin(data.items[i])
                      : null,
                  remove: () => ref
                      .read(activitiesProvider(id).notifier)
                      .remove(data.items[i]),
                  onEdited: (map) {
                    final activity = Activity.maybe(
                      map,
                      Persistence().id!,
                      Persistence().imageQuality,
                    );

                    if (activity == null) return;

                    ref.read(activitiesProvider(id).notifier).replace(activity);
                  },
                  openReplies: () => context.push(
                    Routes.activity(data.items[i].id, id),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/activity/activity_filter_sheet.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activity_card.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/paged_view.dart';

class ActivitiesView extends ConsumerStatefulWidget {
  const ActivitiesView(this.tag);

  final UserActivitiesTag tag;

  @override
  ConsumerState<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends ConsumerState<ActivitiesView> {
  late final _scrollCtrl = PagedController(
    loadMore: () => ref.read(activitiesProvider(widget.tag).notifier).fetch(),
  );

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewerId = ref.watch(viewerIdProvider);
    final userId = widget.tag.userId;

    final floatingAction = viewerId != null
        ? HidingFloatingActionButton(
            key: const Key('post'),
            scrollCtrl: _scrollCtrl,
            child: FloatingActionButton(
              tooltip: userId == viewerId ? 'New Post' : 'New Message',
              child: const Icon(Icons.edit_outlined),
              onPressed: () => showSheet(
                context,
                CompositionView(
                  tag: userId == viewerId
                      ? const StatusActivityCompositionTag(id: null)
                      : MessageActivityCompositionTag(
                          id: null,
                          recipientId: userId,
                        ),
                  onSaved: (map) => ref.read(activitiesProvider(widget.tag).notifier).prepend(map),
                ),
              ),
            ),
          )
        : null;

    return AdaptiveScaffold(
      topBar: TopBar(
        title: 'Activities',
        trailing: [
          IconButton(
            tooltip: 'Filter',
            icon: const Icon(Ionicons.funnel_outline),
            onPressed: () => showActivityFilterSheet(
              context,
              ref,
              widget.tag,
            ),
          ),
        ],
      ),
      floatingAction: floatingAction,
      child: ActivitiesSubView(widget.tag, _scrollCtrl),
    );
  }
}

class ActivitiesSubView extends StatelessWidget {
  const ActivitiesSubView(this.tag, this.scrollCtrl);

  final ActivitiesTag tag;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final viewerId = ref.watch(viewerIdProvider);
        final options = ref.watch(persistenceProvider.select((s) => s.options));

        return PagedView<Activity>(
          provider: activitiesProvider(tag).select(
            (s) => s.unwrapPrevious().whenData((data) => data),
          ),
          scrollCtrl: scrollCtrl,
          onRefresh: (invalidate) {
            invalidate(activitiesProvider(tag));
            if (tag is HomeActivitiesTag) {
              ref.read(settingsProvider.notifier).refetchUnread();
            }
          },
          onData: (data) => SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: data.items.length,
              (context, i) => ActivityCard(
                withHeader: true,
                analogClock: options.analogClock,
                highContrast: options.highContrast,
                activity: data.items[i],
                footer: ActivityFooter(
                  viewerId: viewerId,
                  activity: data.items[i],
                  toggleLike: () =>
                      ref.read(activitiesProvider(tag).notifier).toggleLike(data.items[i]),
                  toggleSubscription: () =>
                      ref.read(activitiesProvider(tag).notifier).toggleSubscription(data.items[i]),
                  togglePin: () =>
                      ref.read(activitiesProvider(tag).notifier).togglePin(data.items[i]),
                  remove: () => ref.read(activitiesProvider(tag).notifier).remove(data.items[i]),
                  onEdited: (map) {
                    final activity = Activity.maybe(
                      map,
                      viewerId,
                      options.imageQuality,
                    );

                    if (activity == null) return;

                    ref.read(activitiesProvider(tag).notifier).replace(activity);
                  },
                  reply: () => context.push(Routes.activity(data.items[i].id, tag)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

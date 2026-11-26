import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/activity/activities_filter_provider.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activity_card.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/paged_view.dart';

class MediaActivitiesSubview extends StatefulWidget {
  const MediaActivitiesSubview({
    required this.ref,
    required this.tag,
    required this.scrollCtrl,
    required this.viewerId,
    required this.options,
  });

  final WidgetRef ref;
  final MediaActivitiesTag tag;
  final ScrollController scrollCtrl;
  final int? viewerId;
  final Options options;

  @override
  State<MediaActivitiesSubview> createState() => _MediaActivitiesSubviewState();
}

class _MediaActivitiesSubviewState extends State<MediaActivitiesSubview>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PagedView(
      scrollCtrl: widget.scrollCtrl,
      onRefresh: (invalidate) => invalidate(activitiesProvider(widget.tag)),
      provider: activitiesProvider(widget.tag),
      header: _FollowingFilterButton(widget.ref, widget.tag),
      onData: (data) => SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: data.items.length,
          (context, i) => ActivityCard(
            withHeader: true,
            analogClock: widget.options.analogClock,
            highContrast: widget.options.highContrast,
            activity: data.items[i],
            footer: ActivityFooter(
              viewerId: widget.viewerId,
              activity: data.items[i],
              toggleLike: () => widget.ref
                  .read(activitiesProvider(widget.tag).notifier)
                  .toggleLike(data.items[i]),
              toggleSubscription: () => widget.ref
                  .read(activitiesProvider(widget.tag).notifier)
                  .toggleSubscription(data.items[i]),
              togglePin: () =>
                  widget.ref.read(activitiesProvider(widget.tag).notifier).togglePin(data.items[i]),
              remove: () =>
                  widget.ref.read(activitiesProvider(widget.tag).notifier).remove(data.items[i]),
              onEdited: (map) {
                final activity = Activity.maybe(map, widget.viewerId, widget.options.imageQuality);

                if (activity == null) return;

                widget.ref.read(activitiesProvider(widget.tag).notifier).replace(activity);
              },
              reply: () => context.push(Routes.activity(data.items[i].id, null)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowingFilterButton extends StatelessWidget {
  const _FollowingFilterButton(this.ref, this.tag);

  final WidgetRef ref;
  final MediaActivitiesTag tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(activitiesFilterProvider(tag));

    return SliverToBoxAdapter(
      child: SizedBox(
        height: Theming.normalTapTarget,
        child: switch (filter) {
          MediaActivitiesFilter filter => Row(
            spacing: Theming.offset,
            children: [
              FilterChip(
                label: Text(l10n.filterActivitiesGlobal),
                selected: filter.socialGroup == .global,
                onSelected: (val) => ref.read(activitiesFilterProvider(tag).notifier).state = filter
                    .copyWith(socialGroup: .global),
              ),
              FilterChip(
                label: Text(l10n.filterActivitiesFollowed),
                selected: filter.socialGroup == .followed,
                onSelected: (val) => ref.read(activitiesFilterProvider(tag).notifier).state = filter
                    .copyWith(socialGroup: .followed),
              ),
              FilterChip(
                label: Text(l10n.filterActivitiesSelf),
                selected: filter.socialGroup == .self,
                onSelected: (val) => ref.read(activitiesFilterProvider(tag).notifier).state = filter
                    .copyWith(socialGroup: .self),
              ),
            ],
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/activity/activities_filter_provider.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activity_card.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/paged_view.dart';

class MediaActivitiesSubview extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PagedView(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(activitiesProvider(tag)),
      provider: activitiesProvider(tag),
      header: _FollowingFilterButton(ref, tag),
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
              togglePin: () => ref.read(activitiesProvider(tag).notifier).togglePin(data.items[i]),
              remove: () => ref.read(activitiesProvider(tag).notifier).remove(data.items[i]),
              onEdited: (map) {
                final activity = Activity.maybe(map, viewerId, options.imageQuality);

                if (activity == null) return;

                ref.read(activitiesProvider(tag).notifier).replace(activity);
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
    final filter = ref.watch(activitiesFilterProvider(tag));

    return SliverToBoxAdapter(
      child: SizedBox(
        height: Theming.normalTapTarget,
        child: switch (filter) {
          MediaActivitiesFilter filter => Row(
            spacing: Theming.offset,
            children: [
              FilterChip(
                label: const Text("Global"),
                selected: filter.socialGroup == .global,
                onSelected: (val) => ref.read(activitiesFilterProvider(tag).notifier).state = filter
                    .copyWith(socialGroup: .global),
              ),
              FilterChip(
                label: const Text("Following"),
                selected: filter.socialGroup == .followed,
                onSelected: (val) => ref.read(activitiesFilterProvider(tag).notifier).state = filter
                    .copyWith(socialGroup: .followed),
              ),
              FilterChip(
                label: const Text("Self"),
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

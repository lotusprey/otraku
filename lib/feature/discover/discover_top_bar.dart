import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_media_filter_view.dart';
import 'package:otraku/feature/discover/discover_recommendations_filter_sheet.dart';
import 'package:otraku/feature/review/reviews_filter_sheet.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/debounce.dart';
import 'package:otraku/widget/input/search_field.dart';
import 'package:otraku/widget/sheets.dart';

class DiscoverTopBarTrailingContent extends StatelessWidget {
  const DiscoverTopBarTrailingContent(this.focusNode);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final filter = ref.watch(discoverFilterProvider);
        final highContrast = ref.watch(persistenceProvider.select((s) => s.options.highContrast));

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: switch (filter.type) {
                  .review => Text(
                    'Reviews',
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: TextTheme.of(context).bodyMedium,
                  ),
                  .recommendation => Text(
                    'Recommendations',
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: TextTheme.of(context).bodyMedium,
                  ),
                  _ => SearchField(
                    debounce: Debounce(),
                    focusNode: focusNode,
                    hint: filter.type.label,
                    value: filter.search,
                    onChanged: (search) => ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(search: search)),
                  ),
                },
              ),
              if (filter.type == .anime)
                IconButton(
                  tooltip: 'Calendar',
                  icon: const Icon(Ionicons.calendar_outline),
                  onPressed: () => context.push(Routes.calendar),
                ),
              switch (filter.type) {
                .anime || .manga =>
                  filter.mediaFilter.isActive
                      ? Badge(
                          smallSize: 10,
                          alignment: Alignment.topLeft,
                          backgroundColor: ColorScheme.of(context).primary,
                          child: _filterIcon(context, ref, filter),
                        )
                      : _filterIcon(context, ref, filter),
                .character || .staff => _BirthdayFilter(ref),
                .review => IconButton(
                  tooltip: 'Filter',
                  icon: const Icon(Ionicons.funnel_outline),
                  onPressed: () => showReviewsFilterSheet(
                    context: context,
                    filter: filter.reviewsFilter,
                    highContrast: highContrast,
                    onDone: (filter) {
                      final discoverFilter = ref.read(discoverFilterProvider);
                      if (filter != discoverFilter.reviewsFilter) {
                        ref
                            .read(discoverFilterProvider.notifier)
                            .update((s) => s.copyWith(reviewsFilter: filter));
                      }
                    },
                  ),
                ),
                .recommendation => IconButton(
                  tooltip: 'Filter',
                  icon: const Icon(Ionicons.funnel_outline),
                  onPressed: () => showRecommendationsFilterSheet(
                    context: context,
                    filter: filter.recommendationsFilter,
                    highContrast: highContrast,
                    onDone: (filter) {
                      final discoverFilter = ref.read(discoverFilterProvider);
                      if (filter != discoverFilter.recommendationsFilter) {
                        ref
                            .read(discoverFilterProvider.notifier)
                            .update((s) => s.copyWith(recommendationsFilter: filter));
                      }
                    },
                  ),
                ),
                _ => const SizedBox(width: Theming.offset),
              },
            ],
          ),
        );
      },
    );
  }

  Widget _filterIcon(BuildContext context, WidgetRef ref, DiscoverFilter filter) {
    return IconButton(
      tooltip: 'Filter',
      icon: const Icon(Ionicons.funnel_outline),
      onPressed: () => showSheet(
        context,
        DiscoverMediaFilterView(
          ofAnime: filter.type == .anime,
          filter: filter.mediaFilter,
          onChanged: (mediaFilter) => ref
              .read(discoverFilterProvider.notifier)
              .update((s) => s.copyWith(mediaFilter: mediaFilter)),
        ),
      ),
    );
  }
}

class _BirthdayFilter extends StatelessWidget {
  const _BirthdayFilter(this.ref);

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final hasBirthday = ref.watch(discoverFilterProvider.select((s) => s.hasBirthday));

    final icon = IconButton(
      tooltip: 'Birthday Filter',
      icon: const Icon(Icons.cake_outlined),
      onPressed: () => ref
          .read(discoverFilterProvider.notifier)
          .update((s) => s.copyWith(hasBirthday: !hasBirthday)),
    );

    return hasBirthday
        ? Badge(
            smallSize: 10,
            alignment: Alignment.topLeft,
            backgroundColor: ColorScheme.of(context).primary,
            child: icon,
          )
        : icon;
  }
}

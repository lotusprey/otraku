import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/discover/discover_filter_view.dart';
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
        final options = ref.watch(persistenceProvider.select((s) => s.options));

        return Expanded(
          child: Row(
            children: [
              if (filter.type != DiscoverType.review)
                Expanded(
                  child: SearchField(
                    debounce: Debounce(),
                    focusNode: focusNode,
                    hint: filter.type.label,
                    value: filter.search,
                    onChanged: (search) => ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(search: search)),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    'Reviews',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              if (filter.type == DiscoverType.anime)
                IconButton(
                  tooltip: 'Calendar',
                  icon: const Icon(Ionicons.calendar_outline),
                  onPressed: () => context.push(Routes.calendar),
                ),
              if (filter.type == DiscoverType.anime ||
                  filter.type == DiscoverType.manga)
                if (filter.mediaFilter.isActive)
                  Badge(
                    smallSize: 10,
                    alignment: Alignment.topLeft,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: _filterIcon(
                      context,
                      ref,
                      filter,
                      options.leftHanded,
                    ),
                  )
                else
                  _filterIcon(context, ref, filter, options.leftHanded)
              else if (filter.type == DiscoverType.character ||
                  filter.type == DiscoverType.staff)
                _BirthdayFilter(ref)
              else if (filter.type == DiscoverType.review)
                IconButton(
                  tooltip: 'Sort',
                  icon: const Icon(Ionicons.funnel_outline),
                  onPressed: () => showReviewsFilterSheet(
                    context: context,
                    filter: filter.reviewsFilter,
                    onDone: (filter) => ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(reviewsFilter: filter)),
                  ),
                )
              else
                const SizedBox(width: Theming.offset),
            ],
          ),
        );
      },
    );
  }

  Widget _filterIcon(
    BuildContext context,
    WidgetRef ref,
    DiscoverFilter filter,
    bool leftHanded,
  ) {
    return IconButton(
      tooltip: 'Filter',
      icon: const Icon(Ionicons.funnel_outline),
      onPressed: () => showSheet(
        context,
        DiscoverFilterView(
          ofAnime: filter.type == DiscoverType.anime,
          filter: filter.mediaFilter,
          leftHanded: leftHanded,
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
    final hasBirthday =
        ref.watch(discoverFilterProvider.select((s) => s.hasBirthday));

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
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: icon,
          )
        : icon;
  }
}

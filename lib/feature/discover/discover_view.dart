import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/filter/filter_discover_view.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/fields/search_field.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_media_grid.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/discover/discover_provider.dart';
import 'package:otraku/feature/review/reviews_filter_sheet.dart';
import 'package:otraku/feature/studio/studio_grid.dart';
import 'package:otraku/feature/user/user_grid.dart';
import 'package:otraku/feature/review/review_grid.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/widget/grids/tile_item_grid.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/widget/paged_view.dart';

class DiscoverSubview extends StatelessWidget {
  const DiscoverSubview(this.focusNode, this.scrollCtrl);

  final FocusNode focusNode;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      topBar: TopBar(trailing: [_TopBarContent(focusNode)]),
      child: _Grid(scrollCtrl),
    );
  }
}

class _TopBarContent extends StatelessWidget {
  const _TopBarContent(this.focusNode);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final filter = ref.watch(discoverFilterProvider);

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
                    child: _filterIcon(context, ref, filter),
                  )
                else
                  _filterIcon(context, ref, filter)
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
  ) {
    return IconButton(
      tooltip: 'Filter',
      icon: const Icon(Ionicons.funnel_outline),
      onPressed: () => showSheet(
        context,
        FilterDiscoverView(
          ofAnime: filter.type == DiscoverType.anime,
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

class _Grid extends StatelessWidget {
  const _Grid(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));
        final onRefresh = (invalidate) => invalidate(discoverProvider);

        switch (type) {
          case DiscoverType.anime:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverAnimeItems).pages,
              onData: (data) => Persistence().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : TileItemGrid(data.items),
            );
          case DiscoverType.manga:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverMangaItems).pages,
              onData: (data) => Persistence().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : TileItemGrid(data.items),
            );
          case DiscoverType.character:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverCharacterItems).pages,
              onData: (data) => TileItemGrid(data.items),
            );
          case DiscoverType.staff:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverStaffItems).pages,
              onData: (data) => TileItemGrid(data.items),
            );
          case DiscoverType.studio:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverStudioItems).pages,
              onData: (data) => StudioGrid(data.items),
            );
          case DiscoverType.user:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverUserItems).pages,
              onData: (data) => UserGrid(data.items),
            );
          case DiscoverType.review:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverReviewItems).pages,
              onData: (data) => ReviewGrid(data.items),
            );
        }
      },
    );
  }
}

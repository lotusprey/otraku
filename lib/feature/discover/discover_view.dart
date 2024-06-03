import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/filter/filter_discover_view.dart';
import 'package:otraku/util/routes.dart';
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
import 'package:otraku/widget/layouts/floating_bar.dart';
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
      topBar: TopBar(canPop: false, trailing: [_TopBarContent(focusNode)]),
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: const [_ActionButton()],
      ),
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
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        return Expanded(
          child: Row(
            children: [
              if (type != DiscoverType.review)
                Expanded(
                  child: SearchField(
                    debounce: Debounce(),
                    focusNode: focusNode,
                    hint: type.label,
                    value: ref.watch(
                      discoverFilterProvider.select((s) => s.search),
                    ),
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
              if (type == DiscoverType.anime)
                TopBarIcon(
                  tooltip: 'Calendar',
                  icon: Ionicons.calendar_outline,
                  onTap: () => context.push(Routes.calendar),
                ),
              if (type == DiscoverType.anime || type == DiscoverType.manga)
                TopBarIcon(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showSheet(
                    context,
                    FilterDiscoverView(
                      ofAnime: type == DiscoverType.anime,
                      filter: ref.read(discoverFilterProvider).mediaFilter,
                      onChanged: (mediaFilter) => ref
                          .read(discoverFilterProvider.notifier)
                          .update((s) => s.copyWith(mediaFilter: mediaFilter)),
                    ),
                  ),
                )
              else if (type == DiscoverType.character ||
                  type == DiscoverType.staff)
                _BirthdayFilter(ref)
              else if (type == DiscoverType.review)
                TopBarIcon(
                  tooltip: 'Sort',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showReviewsFilterSheet(
                    context: context,
                    filter: ref.read(discoverFilterProvider).reviewsFilter,
                    onDone: (filter) => ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(reviewsFilter: filter)),
                  ),
                )
              else
                const SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        return ActionButton(
          tooltip: 'Types',
          icon: _typeIcon(type),
          onTap: () {
            showSheet(
              context,
              GradientSheet([
                for (final discoverType in DiscoverType.values)
                  GradientSheetButton(
                    text: discoverType.label,
                    icon: _typeIcon(discoverType),
                    selected: discoverType == type,
                    onTap: () => ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(type: discoverType)),
                  ),
              ]),
            );
          },
          onSwipe: (goRight) {
            var type = ref.read(discoverFilterProvider).type;

            if (goRight) {
              if (type.index < DiscoverType.values.length - 1) {
                type = DiscoverType.values.elementAt(type.index + 1);
              } else {
                type = DiscoverType.values.first;
              }
            } else {
              if (type.index > 0) {
                type = DiscoverType.values.elementAt(type.index - 1);
              } else {
                type = DiscoverType.values.last;
              }
            }

            ref
                .read(discoverFilterProvider.notifier)
                .update((s) => s.copyWith(type: type));
            return _typeIcon(type);
          },
        );
      },
    );
  }

  static IconData _typeIcon(DiscoverType type) => switch (type) {
        DiscoverType.anime => Ionicons.film_outline,
        DiscoverType.manga => Ionicons.book_outline,
        DiscoverType.character => Ionicons.man_outline,
        DiscoverType.staff => Ionicons.mic_outline,
        DiscoverType.studio => Ionicons.business_outline,
        DiscoverType.user => Ionicons.person_outline,
        DiscoverType.review => Icons.rate_review_outlined,
      };
}

class _BirthdayFilter extends StatelessWidget {
  const _BirthdayFilter(this.ref);

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final hasBirthday =
        ref.watch(discoverFilterProvider.select((s) => s.hasBirthday));

    return TopBarIcon(
      icon: Icons.cake_outlined,
      tooltip: 'Birthday Filter',
      accented: hasBirthday,
      onTap: () => ref
          .read(discoverFilterProvider.notifier)
          .update((s) => s.copyWith(hasBirthday: !hasBirthday)),
    );
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

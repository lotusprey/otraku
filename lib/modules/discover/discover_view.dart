import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/discover/discover_media_grid.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/discover/discover_providers.dart';
import 'package:otraku/modules/filter/filter_view.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/modules/studio/studio_grid.dart';
import 'package:otraku/modules/user/user_grid.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/modules/review/review_grid.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/grids/tile_item_grid.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/modules/filter/filter_search_field.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/paged_view.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      topBar: const TopBar(canPop: false, trailing: [_TopBarContent()]),
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: const [_ActionButton()],
      ),
      child: _Grid(scrollCtrl),
    );
  }
}

class _TopBarContent extends StatelessWidget {
  const _TopBarContent();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        return Expanded(
          child: Row(
            children: [
              CloseableSearchField(
                title: Convert.clarifyEnum(type.name)!,
                value: ref.watch(
                  discoverFilterProvider.select((s) => s.search),
                ),
                onChanged: (search) => ref
                    .read(discoverFilterProvider.notifier)
                    .update((s) => s.copyWith(search: () => search)),
                enabled: type != DiscoverType.review,
              ),
              if (type == DiscoverType.anime || type == DiscoverType.manga)
                TopBarIcon(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showSheet(
                    context,
                    DiscoverFilterView(
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
                  onTap: () {
                    final index =
                        ref.read(discoverFilterProvider).reviewSort.index;

                    final sheetButtons = [
                      for (int i = 0; i < ReviewSort.values.length; i++)
                        GradientSheetButton(
                            text: ReviewSort.values.elementAt(i).text,
                            selected: index == i,
                            onTap: () => ref
                                .read(discoverFilterProvider.notifier)
                                .update(
                                  (s) => s.copyWith(
                                    reviewSort: ReviewSort.values.elementAt(i),
                                  ),
                                )),
                    ];

                    showSheet(context, GradientSheet(sheetButtons));
                  },
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
                for (int i = 0; i < DiscoverType.values.length; i++)
                  GradientSheetButton(
                    text: Convert.clarifyEnum(DiscoverType.values[i].name)!,
                    icon: _typeIcon(DiscoverType.values[i]),
                    selected: type.index == i,
                    onTap: () =>
                        ref.read(discoverFilterProvider.notifier).update(
                              (s) => s.copyWith(type: DiscoverType.values[i]),
                            ),
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
        DiscoverType.manga => Ionicons.bookmark_outline,
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
        final onRefresh = () => ref.invalidate(discoverProvider);

        switch (type) {
          case DiscoverType.anime:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverAnimeItems).pages,
              onData: (data) => Options().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : TileItemGrid(data.items),
            );
          case DiscoverType.manga:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverMangaItems).pages,
              onData: (data) => Options().discoverItemView == 0
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

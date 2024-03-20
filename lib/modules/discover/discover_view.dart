import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/fields/search_field.dart';
import 'package:otraku/modules/discover/discover_media_grid.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/discover/discover_providers.dart';
import 'package:otraku/modules/filter/filter_view.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/modules/studio/studio_grid.dart';
import 'package:otraku/modules/user/user_grid.dart';
import 'package:otraku/modules/review/review_grid.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/grids/tile_item_grid.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/paged_view.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView(this.focusNode, this.scrollCtrl);

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
              if (type != DiscoverType.Review)
                Expanded(
                  child: SearchField(
                    debounce: Debounce(),
                    focusNode: focusNode,
                    hint: type.name.noScreamingSnakeCase,
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
              if (type == DiscoverType.Anime)
                TopBarIcon(
                  tooltip: 'Calendar',
                  icon: Ionicons.calendar_outline,
                  onTap: () => context.push(Routes.calendar),
                ),
              if (type == DiscoverType.Anime || type == DiscoverType.Manga)
                TopBarIcon(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showSheet(
                    context,
                    DiscoverFilterView(
                      ofAnime: type == DiscoverType.Anime,
                      filter: ref.read(discoverFilterProvider).mediaFilter,
                      onChanged: (mediaFilter) => ref
                          .read(discoverFilterProvider.notifier)
                          .update((s) => s.copyWith(mediaFilter: mediaFilter)),
                    ),
                  ),
                )
              else if (type == DiscoverType.Character ||
                  type == DiscoverType.Staff)
                _BirthdayFilter(ref)
              else if (type == DiscoverType.Review)
                TopBarIcon(
                  tooltip: 'Sort',
                  icon: Ionicons.funnel_outline,
                  onTap: () {
                    final current = ref.read(discoverFilterProvider).reviewSort;

                    showSheet(
                      context,
                      GradientSheet([
                        for (final rs in ReviewsSort.values)
                          GradientSheetButton(
                            text: rs.text,
                            selected: rs == current,
                            onTap: () => ref
                                .read(discoverFilterProvider.notifier)
                                .update((s) => s.copyWith(reviewSort: rs)),
                          ),
                      ]),
                    );
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
                for (final dt in DiscoverType.values)
                  GradientSheetButton(
                    text: dt.name.noScreamingSnakeCase,
                    icon: _typeIcon(dt),
                    selected: dt == type,
                    onTap: () => ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(type: dt)),
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
        DiscoverType.Anime => Ionicons.film_outline,
        DiscoverType.Manga => Ionicons.book_outline,
        DiscoverType.Character => Ionicons.man_outline,
        DiscoverType.Staff => Ionicons.mic_outline,
        DiscoverType.Studio => Ionicons.business_outline,
        DiscoverType.User => Ionicons.person_outline,
        DiscoverType.Review => Icons.rate_review_outlined,
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
          case DiscoverType.Anime:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverAnimeItems).pages,
              onData: (data) => Options().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : TileItemGrid(data.items),
            );
          case DiscoverType.Manga:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverMangaItems).pages,
              onData: (data) => Options().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : TileItemGrid(data.items),
            );
          case DiscoverType.Character:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverCharacterItems).pages,
              onData: (data) => TileItemGrid(data.items),
            );
          case DiscoverType.Staff:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverStaffItems).pages,
              onData: (data) => TileItemGrid(data.items),
            );
          case DiscoverType.Studio:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverStudioItems).pages,
              onData: (data) => StudioGrid(data.items),
            );
          case DiscoverType.User:
            return PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverUserItems).pages,
              onData: (data) => UserGrid(data.items),
            );
          case DiscoverType.Review:
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

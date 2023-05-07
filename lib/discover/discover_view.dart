import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/tile_item.dart';
import 'package:otraku/discover/discover_media_grid.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/discover/discover_providers.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/filter/filter_view.dart';
import 'package:otraku/review/review_models.dart';
import 'package:otraku/review/review_providers.dart';
import 'package:otraku/studio/studio_grid.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/user/user_grid.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/review/review_grid.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/widgets/grids/tile_item_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/filter/filter_search_field.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/paged_view.dart';

class DiscoverView extends ConsumerWidget {
  const DiscoverView(this.scrollCtrl);

  final PagedController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onRefresh = () {
      final type = ref.read(discoverFilterProvider).type;
      switch (type) {
        case DiscoverType.anime:
          ref.invalidate(discoverAnimeProvider);
          return;
        case DiscoverType.manga:
          ref.invalidate(discoverMangaProvider);
          return;
        case DiscoverType.character:
          ref.invalidate(discoverCharacterProvider);
          return;
        case DiscoverType.staff:
          ref.invalidate(discoverStaffProvider);
          return;
        case DiscoverType.studio:
          ref.invalidate(discoverStudioProvider);
          return;
        case DiscoverType.user:
          ref.invalidate(discoverUserProvider);
          return;
        case DiscoverType.review:
          ref.invalidate(discoverReviewProvider);
          return;
      }
    };

    return TabScaffold(
      topBar: const TopBar(canPop: false, trailing: [_TopBarContent()]),
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: const [_ActionButton()],
      ),
      child: _Grid(scrollCtrl, onRefresh),
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
              SearchFilterField(
                title: Convert.clarifyEnum(type.name)!,
                enabled: type != DiscoverType.review,
              ),
              if (type == DiscoverType.anime || type == DiscoverType.manga)
                TopBarIcon(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showSheet(
                    context,
                    DiscoverFilterView(
                      filter: ref.read(discoverFilterProvider).filter,
                      onChanged: (filter) =>
                          ref.read(discoverFilterProvider).filter = filter,
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
                        ref.read(reviewSortProvider(null).notifier).state.index;

                    showSheet(
                      context,
                      GradientSheet([
                        for (int i = 0; i < ReviewSort.values.length; i++)
                          GradientSheetButton(
                            text: ReviewSort.values.elementAt(i).text,
                            selected: index == i,
                            onTap: () => ref
                                .read(reviewSortProvider(null).notifier)
                                .state = ReviewSort.values.elementAt(i),
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
          icon: type.icon,
          onTap: () {
            showSheet(
              context,
              GradientSheet([
                for (int i = 0; i < DiscoverType.values.length; i++)
                  GradientSheetButton(
                    text: Convert.clarifyEnum(DiscoverType.values[i].name)!,
                    icon: DiscoverType.values[i].icon,
                    selected: type.index == i,
                    onTap: () => ref.read(discoverFilterProvider).type =
                        DiscoverType.values[i],
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

            ref.read(discoverFilterProvider).type = type;
            return type.icon;
          },
        );
      },
    );
  }
}

class _BirthdayFilter extends StatelessWidget {
  const _BirthdayFilter(this.ref);

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(discoverFilterProvider.select((s) => s.birthday));

    return TopBarIcon(
      icon: Icons.cake_outlined,
      tooltip: 'Birthday Filter',
      onTap: () => ref.read(discoverFilterProvider).birthday = !value,
      accented: value,
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid(this.scrollCtrl, this.onRefresh);

  final ScrollController scrollCtrl;
  final void Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        switch (type) {
          case DiscoverType.anime:
            return PagedView<DiscoverMediaItem>(
              provider: discoverAnimeProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) => Options().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : TileItemGrid(data.items),
            );
          case DiscoverType.manga:
            return PagedView<DiscoverMediaItem>(
              provider: discoverMangaProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) => Options().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : TileItemGrid(data.items),
            );
          case DiscoverType.character:
            return PagedView<TileItem>(
              provider: discoverCharacterProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) => TileItemGrid(data.items),
            );
          case DiscoverType.staff:
            return PagedView<TileItem>(
              provider: discoverStaffProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) => TileItemGrid(data.items),
            );
          case DiscoverType.studio:
            return PagedView<StudioItem>(
              provider: discoverStudioProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) => StudioGrid(data.items),
            );
          case DiscoverType.user:
            return PagedView<UserItem>(
              provider: discoverUserProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) => UserGrid(data.items),
            );
          case DiscoverType.review:
            return PagedView<ReviewItem>(
              provider: discoverReviewProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) => ReviewGrid(data.items),
            );
        }
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/statistics/charts.dart';

class MediaStatsSubview extends StatelessWidget {
  const MediaStatsSubview({
    required this.ref,
    required this.info,
    required this.stats,
    required this.scrollCtrl,
    required this.highContrast,
  });

  final WidgetRef ref;
  final MediaInfo info;
  final MediaStats stats;
  final ScrollController scrollCtrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return ConstrainedView(
      child: CustomScrollView(
        controller: scrollCtrl,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).top)),
          if (stats.ranks.isNotEmpty)
            _MediaRankGrid(ref: ref, info: info, highContrast: highContrast, ranks: stats.ranks),
          if (stats.scoreNames.isNotEmpty)
            SliverToBoxAdapter(
              child: BarChart(
                title: 'Score Distribution',
                names: stats.scoreNames.map((n) => n.toString()).toList(),
                values: stats.scoreValues,
              ),
            ),
          if (stats.statusNames.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const .only(top: Theming.offset),
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    title: 'Status Distribution',
                    names: stats.statusNames,
                    values: stats.statusValues,
                    highContrast: highContrast,
                  ),
                ),
              ),
            ),
          const SliverFooter(),
        ],
      ),
    );
  }
}

class _MediaRankGrid extends StatelessWidget {
  const _MediaRankGrid({
    required this.ref,
    required this.info,
    required this.highContrast,
    required this.ranks,
  });

  final WidgetRef ref;
  final MediaInfo info;
  final bool highContrast;
  final List<MediaRank> ranks;

  @override
  Widget build(BuildContext context) {
    final bodyMediumLineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final tileHeight = max(bodyMediumLineHeight * 2, Theming.iconBig) + 10;

    return SliverPadding(
      padding: const .symmetric(vertical: Theming.offset),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
          height: tileHeight,
          minWidth: 185,
        ),
        delegate: SliverChildBuilderDelegate((_, i) {
          return CardExtension.highContrast(highContrast)(
            child: InkWell(
              borderRadius: Theming.borderRadiusSmall,
              onTap: () {
                final notifier = ref.read(discoverFilterProvider.notifier);
                final filter = notifier.state.copyWith(
                  type: info.isAnime ? .anime : .manga,
                  search: '',
                  mediaFilter: DiscoverMediaFilter(notifier.state.mediaFilter.sort),
                );

                filter.mediaFilter.season = ranks[i].season;
                filter.mediaFilter.startYearFrom = ranks[i].year;
                filter.mediaFilter.startYearTo = ranks[i].year;
                filter.mediaFilter.sort = ranks[i].typeIsScore ? .scoreDesc : .popularityDesc;
                if (info.format != null) {
                  if (info.isAnime) {
                    filter.mediaFilter.animeFormats.add(info.format!);
                  } else {
                    filter.mediaFilter.mangaFormats.add(info.format!);
                  }
                }
                notifier.state = filter;

                context.go(Routes.home(.discover));
              },
              child: Padding(
                padding: const .symmetric(horizontal: Theming.offset, vertical: 5),
                child: Row(
                  spacing: Theming.offset,
                  children: [
                    Icon(
                      ranks[i].typeIsScore ? Ionicons.star : Icons.favorite_rounded,
                      color: ColorScheme.of(context).onSurfaceVariant,
                    ),
                    Expanded(child: Text(ranks[i].text, overflow: .ellipsis, maxLines: 2)),
                  ],
                ),
              ),
            ),
          );
        }, childCount: ranks.length),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/grids/sliver_grid_delegates.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/filter/filter_discover_model.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/statistics/charts.dart';

class MediaStatsSubview extends StatelessWidget {
  const MediaStatsSubview({
    required this.ref,
    required this.info,
    required this.stats,
    required this.scrollCtrl,
  });

  final WidgetRef ref;
  final MediaInfo info;
  final MediaStats stats;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return ConstrainedView(
      child: CustomScrollView(
        controller: scrollCtrl,
        slivers: [
          if (stats.ranks.isNotEmpty)
            _MediaRankGrid(
              ref: ref,
              info: info,
              ranks: stats.ranks,
            ),
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
                padding: const EdgeInsets.only(top: 10),
                child: PieChart(
                  title: 'Status Distribution',
                  names: stats.statusNames,
                  values: stats.statusValues,
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
    required this.ranks,
  });

  final WidgetRef ref;
  final MediaInfo info;
  final List<MediaRank> ranks;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          height: Theming.tapTargetSize,
          minWidth: 185,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            return Card(
              child: InkWell(
                borderRadius: Theming.borderRadiusSmall,
                onTap: () {
                  final notifier = ref.read(discoverFilterProvider.notifier);
                  final filter = notifier.state.copyWith(
                    type: info.type,
                    search: '',
                    mediaFilter: DiscoverMediaFilter(),
                  );
                  filter.mediaFilter.season = ranks[i].season;
                  filter.mediaFilter.startYearFrom = ranks[i].year;
                  filter.mediaFilter.startYearTo = ranks[i].year;
                  filter.mediaFilter.sort = ranks[i].typeIsScore
                      ? MediaSort.scoreDesc
                      : MediaSort.popularityDesc;
                  if (info.format != null) {
                    if (info.type == DiscoverType.anime) {
                      filter.mediaFilter.animeFormats.add(info.format!);
                    } else {
                      filter.mediaFilter.mangaFormats.add(info.format!);
                    }
                  }
                  notifier.state = filter;

                  context.go(Routes.home(HomeTab.discover));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ranks[i].typeIsScore
                            ? Ionicons.star
                            : Icons.favorite_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          ranks[i].text,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: ranks.length,
        ),
      ),
    );
  }
}

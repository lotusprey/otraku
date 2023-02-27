import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/statistics/charts.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';

class MediaSocialView extends StatelessWidget {
  const MediaSocialView(this.id, this.media, this.tabToggled, this.toggleTab);

  final int id;
  final Media media;
  final bool tabToggled;
  final void Function(bool) toggleTab;

  @override
  Widget build(BuildContext context) {
    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;
    final stats = media.stats;

    return TabScaffold(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        centered: true,
        children: [
          ActionTabSwitcher(
            items: const ['Reviews', 'Stats'],
            current: tabToggled ? 1 : 0,
            onChanged: (i) => toggleTab(i == 1),
          ),
        ],
      ),
      child: DirectPageView(
        onChanged: null,
        current: tabToggled ? 1 : 0,
        children: [
          Consumer(
            child: SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            builder: (context, ref, overlapInjector) {
              return ref
                  .watch(mediaContentProvider(id).select((s) => s.reviews))
                  .when(
                    loading: () => const Center(child: Loader()),
                    error: (_, __) => const Center(
                      child: Text('Failed to load reviews'),
                    ),
                    data: (data) => CustomScrollView(
                      controller: scrollCtrl,
                      slivers: [
                        overlapInjector!,
                        _ReviewGrid(data.items, media.info.banner),
                        SliverFooter(loading: data.hasNext),
                      ],
                    ),
                  );
            },
          ),
          CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              if (stats.rankTexts.isNotEmpty)
                _Ranks(stats.rankTexts, stats.rankTypes),
              if (stats.scoreNames.isNotEmpty)
                _Scores(stats.scoreNames, stats.scoreValues),
              if (stats.statusNames.isNotEmpty)
                _Statuses(stats.statusNames, stats.statusValues),
              const SliverFooter(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewGrid extends StatelessWidget {
  const _ReviewGrid(this.items, this.bannerUrl);

  final List<RelatedReview> items;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No reviews')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 300,
          height: 140,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: items.length,
          (context, i) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinkTile(
                id: items[i].userId,
                info: items[i].avatar,
                discoverType: DiscoverType.user,
                child: Row(
                  children: [
                    Hero(
                      tag: items[i].userId,
                      child: ClipRRect(
                        borderRadius: Consts.borderRadiusMin,
                        child: FadeImage(
                          items[i].avatar,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(items[i].username),
                    const Spacer(),
                    const Icon(Icons.thumb_up_outlined, size: Consts.iconSmall),
                    const SizedBox(width: 10),
                    Text(
                      items[i].rating,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: LinkTile(
                  id: items[i].reviewId,
                  info: bannerUrl,
                  discoverType: DiscoverType.review,
                  child: Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: Consts.padding,
                        child: Text(
                          items[i].summary,
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ranks extends StatelessWidget {
  const _Ranks(this.rankTexts, this.rankTypes);

  final List<String> rankTexts;
  final List<bool> rankTypes;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          height: Consts.tapTargetSize,
          minWidth: 185,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Icon(
                    rankTypes[i] ? Ionicons.star : Icons.favorite_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      rankTexts[i],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          childCount: rankTexts.length,
        ),
      ),
    );
  }
}

class _Scores extends StatelessWidget {
  const _Scores(this.scoreNames, this.scoreValues);

  final List<int> scoreNames;
  final List<int> scoreValues;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: BarChart(
          title: 'Score Distribution',
          names: scoreNames.map((n) => n.toString()).toList(),
          values: scoreValues,
        ),
      );
}

class _Statuses extends StatelessWidget {
  const _Statuses(this.statusNames, this.statusValues);

  final List<String> statusNames;
  final List<int> statusValues;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: PieChart(
            title: 'Status Distribution',
            names: statusNames,
            values: statusValues,
          ),
        ),
      );
}

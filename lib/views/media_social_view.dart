import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/statistics/charts.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/segment_switcher.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';

class MediaSocialView extends StatelessWidget {
  const MediaSocialView(this.ctrl);

  final MediaController ctrl;

  @override
  Widget build(BuildContext context) {
    final model = ctrl.model!;

    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;

    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        centered: true,
        children: [
          SegmentSwitcher(
            items: const ['Reviews', 'Stats'],
            current: ctrl.socialTabToggled ? 1 : 0,
            onChanged: (i) {
              scrollCtrl.scrollToTop();
              ctrl.socialTabToggled = i == 1;
            },
          ),
        ],
      ),
      child: DirectPageView(
        onChanged: null,
        current: ctrl.socialTabToggled ? 1 : 0,
        children: [
          CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              _ReviewGrid(model.reviews.items, model.info.banner),
              SliverFooter(loading: model.reviews.hasNextPage),
            ],
          ),
          CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              if (model.stats.rankTexts.isNotEmpty)
                _Ranks(model.stats.rankTexts, model.stats.rankTypes),
              if (model.stats.scoreNames.isNotEmpty)
                _Scores(model.stats.scoreNames, model.stats.scoreValues),
              if (model.stats.statusNames.isNotEmpty)
                _Statuses(model.stats.statusNames, model.stats.statusValues),
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

  final List<RelatedReviewModel> items;
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
                          style: Theme.of(context).textTheme.subtitle1,
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

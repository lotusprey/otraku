import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/pie_chart.dart';

abstract class MediaSocialView {
  static List<Widget> children(
    BuildContext ctx,
    MediaController ctrl,
    double headerOffset,
  ) {
    final model = ctrl.model!;

    return [
      SliverShadowAppBar([
        BubbleTabs(
          items: const {
            'Reviews': MediaController.REVIEWS,
            'Stats': MediaController.STATS,
          },
          current: () => ctrl.socialTab,
          onChanged: (int val) {
            ctrl.scrollUpTo(headerOffset);
            ctrl.socialTab = val;
          },
          onSame: () => ctrl.scrollUpTo(headerOffset),
        ),
      ]),
      if (ctrl.socialTab == MediaController.REVIEWS)
        _ReviewGrid(model.reviews.items, model.info.banner)
      else ...[
        if (model.stats.ranks.isNotEmpty) _Ranks(model.stats.ranks),
        if (model.stats.scores.isNotEmpty) _Scores(model.stats.scores),
        if (model.stats.statuses.isNotEmpty) _Statuses(model.stats.statuses),
      ],
    ];
  }
}

class _ReviewGrid extends StatelessWidget {
  _ReviewGrid(this.items, this.bannerUrl);

  final List<RelatedReviewModel> items;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No reviews',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );

    return SliverPadding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExploreIndexer(
                id: items[i].userId,
                imageUrl: items[i].avatar,
                explorable: Explorable.user,
                child: Row(
                  children: [
                    Hero(
                      tag: items[i].userId,
                      child: ClipRRect(
                        borderRadius: Config.BORDER_RADIUS,
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
                child: ExploreIndexer(
                  id: items[i].reviewId,
                  imageUrl: bannerUrl,
                  explorable: Explorable.review,
                  child: Container(
                    width: double.infinity,
                    padding: Config.PADDING,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: Config.BORDER_RADIUS,
                    ),
                    child: Text(
                      items[i].summary,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          childCount: items.length,
        ),
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 300,
          height: 140,
        ),
      ),
    );
  }
}

class _Ranks extends StatelessWidget {
  _Ranks(this.ranks);
  final Map<String, bool> ranks;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          height: Config.MATERIAL_TAP_TARGET_SIZE,
          minWidth: 185,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: Config.BORDER_RADIUS,
            ),
            child: Row(
              children: [
                Icon(
                  ranks.values.elementAt(i)
                      ? Ionicons.star
                      : Icons.favorite_rounded,
                  size: Theming.ICON_BIG,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    ranks.keys.elementAt(i),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          childCount: ranks.length,
        ),
      ),
    );
  }
}

class _Scores extends StatelessWidget {
  _Scores(this.scores);
  final Map<int, int> scores;

  @override
  Widget build(BuildContext context) {
    double max = 200;
    int maxScore = 0;
    for (final s in scores.values) if (maxScore < s) maxScore = s;
    max /= maxScore;

    return SliverToBoxAdapter(
      child: Container(
        height: 310,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Text(
                'Score Distribution',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: Config.PHYSICS,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                itemExtent: 60,
                itemCount: scores.length,
                itemBuilder: (_, i) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        scores.values.elementAt(i).toString(),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Container(
                        height: scores.values.elementAt(i) * max,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.5, 1],
                            colors: [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        scores.keys.elementAt(i).toString(),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Statuses extends StatelessWidget {
  _Statuses(this.statuses);
  final Map<String, int> statuses;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 260,
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Distribution',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Container(
                padding: Config.PADDING,
                decoration: BoxDecoration(
                  borderRadius: Config.BORDER_RADIUS,
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.5, 1],
                    colors: [
                      Theme.of(context).colorScheme.surface.withOpacity(0.4),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Flexible(child: PieChart(statuses.values.toList())),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 0; i < statuses.length; i++)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(statuses.keys.elementAt(i)),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  statuses.values.elementAt(i).toString(),
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

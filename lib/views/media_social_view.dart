import 'package:flutter/material.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';

abstract class MediaSocialView {
  static List<Widget> children(
    BuildContext ctx,
    MediaController ctrl,
    double headerOffset,
  ) =>
      [
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
        SliverPadding(
          padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
          sliver: ctrl.socialTab == MediaController.REVIEWS
              ? _ReviewGrid(ctrl.model!.reviews.items, ctrl.model!.info.banner)
              : _Statistics(),
        ),
      ];
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

    return SliverGrid(
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
    );
  }
}

class _Statistics extends StatelessWidget {
  _Statistics();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter();
  }
}

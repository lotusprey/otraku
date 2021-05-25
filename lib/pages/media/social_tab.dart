import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/triangle_clip.dart';

class SocialTab extends StatelessWidget {
  final Media media;

  SocialTab(this.media);

  @override
  Widget build(BuildContext context) {
    final clipper = ClipPath(
      clipper: TriangleClip(),
      child: Container(
        width: 50,
        height: 10,
        color: Theme.of(context).primaryColor,
      ),
    );

    return SliverPadding(
      padding: Config.PADDING,
      sliver: Obx(() {
        if (media.model!.reviews.items.isEmpty)
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'No reviews',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
            ),
          );

        final items = media.model!.reviews.items;

        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              if (index == items.length - 5) media.fetchReviewPage();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExploreIndexer(
                    id: items[index].userId,
                    imageUrl: items[index].avatar,
                    browsable: Explorable.user,
                    child: Row(
                      children: [
                        Hero(
                          tag: items[index].userId,
                          child: ClipRRect(
                            borderRadius: Config.BORDER_RADIUS,
                            child: FadeImage(
                              items[index].avatar,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(items[index].username),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  clipper,
                  Expanded(
                    child: ExploreIndexer(
                      id: items[index].reviewId,
                      imageUrl: media.model!.overview.banner,
                      browsable: Explorable.review,
                      child: Container(
                        width: double.infinity,
                        padding: Config.PADDING,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: Config.BORDER_RADIUS,
                        ),
                        child: Text(
                          items[index].summary,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            childCount: items.length,
          ),
          gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
            minWidth: 300,
            height: 140,
          ),
        );
      }),
    );
  }
}

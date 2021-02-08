import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/layouts/custom_grid_delegate.dart';
import 'package:otraku/tools/triangle_clip.dart';

class SocialTab extends StatelessWidget {
  final Media media;

  SocialTab(this.media);

  @override
  Widget build(BuildContext context) {
    final clipper = TriangleClip();
    return SliverPadding(
      padding: Config.PADDING,
      sliver: Obx(() {
        if ((media.reviews?.items?.length ?? 0) == 0)
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'No reviews',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
            ),
          );

        final items = media.reviews.items;

        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              if (index == items.length - 5) media.fetchReviewPage();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrowseIndexer(
                    id: items[index].userId,
                    imageUrl: items[index].avatar,
                    browsable: Browsable.user,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Hero(
                          tag: items[index].userId.toString(),
                          child: ClipRRect(
                            borderRadius: Config.BORDER_RADIUS,
                            child: FadeInImage.memoryNetwork(
                              image: items[index].avatar,
                              placeholder: FnHelper.transparentImage,
                              fadeInDuration: Config.FADE_DURATION,
                              fit: BoxFit.cover,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          items[index].username,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  ClipPath(
                    clipper: clipper,
                    child: Container(
                      width: 50,
                      height: 10,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: BrowseIndexer(
                      id: items[index].reviewId,
                      imageUrl: media.overview.banner,
                      browsable: Browsable.review,
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

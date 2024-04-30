import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';

class ReviewGrid extends StatelessWidget {
  const ReviewGrid(this.items);

  final List<ReviewItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 270,
        height: 200,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i]),
        childCount: items.length,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item);

  final ReviewItem item;

  @override
  Widget build(BuildContext context) {
    return LinkTile(
      id: item.id,
      info: item.bannerUrl,
      discoverType: DiscoverType.review,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.bannerUrl != null)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Consts.radiusMin),
                  child: Hero(
                    tag: item.id,
                    child: CachedImage(item.bannerUrl!),
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: Consts.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Review of ${item.mediaTitle} by ${item.userName}',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.summary,
                              style: Theme.of(context).textTheme.labelMedium,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.thumb_up_outlined,
                                  size: Consts.iconSmall,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.rating,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
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

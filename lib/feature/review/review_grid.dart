import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/review/review_models.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

class ReviewGrid extends StatelessWidget {
  const ReviewGrid(this.items, this.highContrast);

  final List<ReviewItem> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 270,
        height: 200,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i], highContrast),
        childCount: items.length,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item, this.highContrast);

  final ReviewItem item;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return CardExtension.highContrast(highContrast)(
      child: InkWell(
        borderRadius: Theming.borderRadiusSmall,
        onTap: () => context.push(Routes.review(item.id, item.bannerUrl)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.bannerUrl != null)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Theming.radiusSmall),
                  child: Hero(
                    tag: item.id,
                    child: CachedImage(item.bannerUrl!),
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: Theming.paddingAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Review of ${item.mediaTitle} by ${item.userName}',
                          style: TextTheme.of(context).titleMedium,
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
                              style: TextTheme.of(context).labelMedium,
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
                                  size: Theming.iconSmall,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.rating,
                                  style: TextTheme.of(context).labelMedium,
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

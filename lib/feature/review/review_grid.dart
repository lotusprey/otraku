import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/build_context_extension.dart';
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
    final bodyMediumLineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final labelMediumLineHeight = context.lineHeight(TextTheme.of(context).labelMedium!);
    final detailsHeight = max(
      labelMediumLineHeight * 2,
      labelMediumLineHeight + Theming.iconSmall + 5,
    );
    final textHeight = bodyMediumLineHeight * 2 + detailsHeight + 15;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 270,
        height: textHeight + 100,
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
          crossAxisAlignment: .stretch,
          children: [
            SizedBox(
              height: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Theming.radiusSmall),
                child: item.bannerUrl != null
                    ? Hero(tag: item.id, child: CachedImage(item.bannerUrl!))
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).surfaceContainerHighest,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: .symmetric(horizontal: Theming.offset, vertical: 5),
                child: Column(
                  crossAxisAlignment: .stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 5,
                  children: [
                    Text(
                      'Review of ${item.mediaTitle} by ${item.userName}',
                      style: TextTheme.of(context).bodyMedium,
                      overflow: .ellipsis,
                      maxLines: 2,
                    ),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.summary,
                            style: TextTheme.of(context).labelMedium,
                            overflow: .ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Padding(
                          padding: const .symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: .center,
                            spacing: 5,
                            children: [
                              const Icon(Icons.thumb_up_outlined, size: Theming.iconSmall),
                              Text(item.rating, style: TextTheme.of(context).labelMedium),
                            ],
                          ),
                        ),
                      ],
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

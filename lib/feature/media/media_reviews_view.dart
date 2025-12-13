import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/media/media_provider.dart';

class MediaReviewsSubview extends StatelessWidget {
  const MediaReviewsSubview({
    required this.id,
    required this.scrollCtrl,
    required this.bannerUrl,
    required this.highContrast,
  });

  final int id;
  final ScrollController scrollCtrl;
  final String? bannerUrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return PagedView<RelatedReview>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaConnectionsProvider(id)),
      provider: mediaConnectionsProvider(
        id,
      ).select((s) => s.unwrapPrevious().whenData((data) => data.reviews)),
      onData: (data) => _MediaReviewGrid(data.items, bannerUrl, highContrast),
    );
  }
}

class _MediaReviewGrid extends StatelessWidget {
  const _MediaReviewGrid(this.items, this.bannerUrl, this.highContrast);

  final List<RelatedReview> items;
  final String? bannerUrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No results')));
    }

    const avatarSize = 50.0;
    const verticalDivider = SizedBox(height: 20, child: VerticalDivider(thickness: 1, width: 20));

    final bodyMediumLineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final tileHeight = max(avatarSize, bodyMediumLineHeight) + bodyMediumLineHeight * 3 + 25;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 300, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => Column(
          crossAxisAlignment: .start,
          spacing: 5,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: .opaque,
                    onTap: () => context.push(Routes.user(items[i].userId, items[i].avatar)),
                    child: Row(
                      mainAxisSize: .min,
                      spacing: Theming.offset,
                      children: [
                        ClipRRect(
                          borderRadius: Theming.borderRadiusSmall,
                          child: CachedImage(
                            items[i].avatar,
                            height: avatarSize,
                            width: avatarSize,
                          ),
                        ),
                        Flexible(child: Text(items[i].username, overflow: .ellipsis, maxLines: 1)),
                      ],
                    ),
                  ),
                ),
                verticalDivider,
                Tooltip(
                  message: 'Reviewer Score',
                  triggerMode: .tap,
                  child: Row(
                    mainAxisSize: .min,
                    spacing: 5,
                    children: [
                      const Icon(Icons.star_half_rounded, size: Theming.iconSmall),
                      Text(items[i].score.toString()),
                    ],
                  ),
                ),
                verticalDivider,
                Tooltip(
                  message: 'Review Rating',
                  triggerMode: .tap,
                  child: Row(
                    mainAxisSize: .min,
                    spacing: 5,
                    children: [
                      const Icon(Icons.thumb_up_outlined, size: Theming.iconSmall),
                      Text(items[i].rating),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: GestureDetector(
                behavior: .opaque,
                onTap: () => context.push(Routes.review(items[i].reviewId, bannerUrl)),
                child: CardExtension.highContrast(highContrast)(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: Theming.paddingAll,
                      child: Text(items[i].summary, overflow: .ellipsis, maxLines: 3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

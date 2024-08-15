import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  });

  final int id;
  final ScrollController scrollCtrl;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<RelatedReview>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaConnectionsProvider(id)),
      provider: mediaConnectionsProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.reviews),
      ),
      onData: (data) => _MediaReviewGrid(data.items, bannerUrl),
    );
  }
}

class _MediaReviewGrid extends StatelessWidget {
  const _MediaReviewGrid(this.items, this.bannerUrl);

  final List<RelatedReview> items;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No results')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 140,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(
                Routes.user(items[i].userId, items[i].avatar),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: items[i].userId,
                    child: ClipRRect(
                      borderRadius: Theming.borderRadiusSmall,
                      child: CachedImage(
                        items[i].avatar,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  const SizedBox(width: Theming.offset),
                  Text(items[i].username),
                  const Spacer(),
                  const Icon(Icons.thumb_up_outlined, size: Theming.iconSmall),
                  const SizedBox(width: Theming.offset),
                  Text(
                    items[i].rating,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(
                  Routes.review(items[i].reviewId, bannerUrl),
                ),
                child: Card(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: Theming.paddingAll,
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
    );
  }
}

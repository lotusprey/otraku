import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/media/media_provider.dart';

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
      withTopOffset: false,
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaRelationsProvider(id)),
      provider: mediaRelationsProvider(id).select(
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
                      child: CachedImage(
                        items[i].avatar,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(items[i].username),
                  const Spacer(),
                  const Icon(Icons.thumb_up_outlined, size: Consts.iconSmall),
                  const SizedBox(width: 10),
                  Text(
                    items[i].rating,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
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

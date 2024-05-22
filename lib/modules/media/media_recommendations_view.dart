import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/media/media_provider.dart';

class MediaRecommendationsSubview extends StatelessWidget {
  const MediaRecommendationsSubview({
    required this.id,
    required this.scrollCtrl,
  });

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<Recommendation>(
      withTopOffset: false,
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaRelationsProvider(id)),
      provider: mediaRelationsProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.recommendations),
      ),
      onData: (data) => _MediaRecommendationsGrid(id, data.items),
    );
  }
}

class _MediaRecommendationsGrid extends StatelessWidget {
  const _MediaRecommendationsGrid(this.mediaId, this.items);

  final int mediaId;
  final List<Recommendation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No results')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 70,
        rawHWRatio: Consts.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => Card(
          child: LinkTile(
            id: items[i].id,
            discoverType: items[i].type,
            info: items[i].imageUrl,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: items[i].id,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: CachedImage(items[i].imageUrl!),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: SizedBox(
                    height: 35,
                    child: Text(
                      items[i].title,
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: _RecommendationRating(mediaId, items[i]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendationRating extends StatefulWidget {
  const _RecommendationRating(this.mediaId, this.item);

  final int mediaId;
  final Recommendation item;

  @override
  State<_RecommendationRating> createState() => _RecommendationRatingState();
}

class _RecommendationRatingState extends State<_RecommendationRating> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: 'Agree',
            child: InkResponse(
              onTap: () {
                final oldRating = widget.item.rating;
                final oldUserRating = widget.item.userRating;

                setState(() {
                  switch (widget.item.userRating) {
                    case true:
                      widget.item.rating--;
                      widget.item.userRating = null;
                      break;
                    case false:
                      widget.item.rating += 2;
                      widget.item.userRating = true;
                      break;
                    case null:
                      widget.item.rating++;
                      widget.item.userRating = true;
                      break;
                  }
                });

                rateRecommendation(
                  widget.mediaId,
                  widget.item.id,
                  widget.item.userRating,
                ).then((ok) {
                  if (!ok) {
                    setState(() {
                      widget.item.rating = oldRating;
                      widget.item.userRating = oldUserRating;
                    });
                  }
                });
              },
              child: widget.item.userRating == true
                  ? Icon(
                      Icons.thumb_up,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Icon(
                      Icons.thumb_up_outlined,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
            ),
          ),
          const SizedBox(width: 5),
          Text(widget.item.rating.toString(), overflow: TextOverflow.fade),
          const SizedBox(width: 5),
          Tooltip(
            message: 'Disagree',
            child: InkResponse(
              onTap: () {
                final oldRating = widget.item.rating;
                final oldUserRating = widget.item.userRating;

                setState(() {
                  switch (widget.item.userRating) {
                    case true:
                      widget.item.rating -= 2;
                      widget.item.userRating = false;
                      break;
                    case false:
                      widget.item.rating++;
                      widget.item.userRating = null;
                      break;
                    case null:
                      widget.item.rating--;
                      widget.item.userRating = false;
                      break;
                  }
                });

                rateRecommendation(
                  widget.mediaId,
                  widget.item.id,
                  widget.item.userRating,
                ).then((ok) {
                  if (!ok) {
                    setState(() {
                      widget.item.rating = oldRating;
                      widget.item.userRating = oldUserRating;
                    });
                  }
                });
              },
              child: widget.item.userRating == false
                  ? Icon(
                      Icons.thumb_down,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.error,
                    )
                  : Icon(
                      Icons.thumb_down_outlined,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/widgets/entry_labels.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/media/media_providers.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/text_rail.dart';

class MediaRelatedGrid extends StatelessWidget {
  const MediaRelatedGrid(this.items);

  final List<RelatedMedia> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No results')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 230,
        height: 100,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) {
          final details = <String, bool>{
            if (items[i].relationType != null) items[i].relationType!: true,
            if (items[i].format != null) items[i].format!: false,
            if (items[i].status != null) items[i].status!: false,
          };

          return LinkTile(
            id: items[i].id,
            info: items[i].imageUrl,
            discoverType: items[i].type,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                    tag: items[i].id,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: CachedImage(
                          items[i].imageUrl,
                          width: 100 / Consts.coverHtoWRatio,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: Consts.padding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              items[i].title,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextRail(
                            details,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MediaReviewGrid extends StatelessWidget {
  const MediaReviewGrid(this.items, this.bannerUrl);

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
              discoverType: DiscoverType.User,
              additionalData: items[i].username,
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
                discoverType: DiscoverType.Review,
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

class MediaFollowingGrid extends StatelessWidget {
  const MediaFollowingGrid(this.items);

  final List<MediaFollowing> items;

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
        height: 70,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => LinkTile(
          id: items[i].userId,
          info: items[i].userAvatar,
          discoverType: DiscoverType.User,
          additionalData: items[i].userName,
          child: Card(
            child: Row(
              children: [
                Hero(
                  tag: items[i].userId,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Consts.radiusMin,
                    ),
                    child: CachedImage(items[i].userAvatar, width: 70),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].userName),
                        SizedBox(
                          height: 35,
                          child: Row(
                            children: [
                              Expanded(child: Text(items[i].status)),
                              Expanded(
                                child: Center(
                                  child: NotesLabel(items[i].notes),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: ScoreLabel(
                                    items[i].score,
                                    items[i].scoreFormat,
                                  ),
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
        ),
      ),
    );
  }
}

class MediaRecommendationGrid extends StatelessWidget {
  const MediaRecommendationGrid(this.mediaId, this.items);

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
                        color: Theme.of(context).colorScheme.surfaceVariant,
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
                      color: Theme.of(context).colorScheme.onBackground,
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
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaRankGrid extends StatelessWidget {
  const MediaRankGrid(this.rankTexts, this.rankTypes);

  final List<String> rankTexts;
  final List<bool> rankTypes;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          height: Consts.tapTargetSize,
          minWidth: 185,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Icon(
                    rankTypes[i] ? Ionicons.star : Icons.favorite_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      rankTexts[i],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          childCount: rankTexts.length,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

typedef RateRecommendation =
    Future<Object?> Function(int mediaId, int recommendedMediaId, bool? rating);

class DiscoverRecommendationsGrid extends StatelessWidget {
  const DiscoverRecommendationsGrid(this.items, this.onRate);

  final List<DiscoverRecommendationItem> items;
  final RateRecommendation onRate;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No items')));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 300, height: 163),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => _Tile(items[i], onRate),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item, this.onRate);

  final DiscoverRecommendationItem item;
  final RateRecommendation onRate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 115,
            child: Row(
              children: [
                MediaRouteTile(
                  id: item.mediaId,
                  imageUrl: item.mediaCover,
                  child: ClipRRect(
                    borderRadius: Theming.borderRadiusSmall,
                    child: CachedImage(item.mediaCover, width: 80),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const .all(Theming.offset),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            behavior: .opaque,
                            onTap: () => context.push(Routes.media(item.mediaId, item.mediaCover)),
                            child: Text(item.mediaTitle, overflow: .fade, maxLines: 3),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            behavior: .opaque,
                            onTap: () => context.push(
                              Routes.media(item.recommendedMediaId, item.recommendedMediaCover),
                            ),
                            child: Text(
                              item.recommendedMediaTitle,
                              overflow: .fade,
                              textAlign: .end,
                              maxLines: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                MediaRouteTile(
                  id: item.recommendedMediaId,
                  imageUrl: item.recommendedMediaCover,
                  child: ClipRRect(
                    borderRadius: Theming.borderRadiusSmall,
                    child: CachedImage(item.recommendedMediaCover, width: 80),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: Theming.offset),
            child: Row(
              spacing: 5,
              mainAxisAlignment: .spaceBetween,
              children: [
                Expanded(
                  child: item.mediaListStatus == null
                      ? const SizedBox()
                      : Text(item.mediaListStatus!, textAlign: .left),
                ),
                _RecommendationButtons(item, onRate),
                Expanded(
                  child: item.recommendedMediaListStatus == null
                      ? const SizedBox()
                      : Text(item.recommendedMediaListStatus!, textAlign: .right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationButtons extends StatefulWidget {
  const _RecommendationButtons(this.item, this.onRate);

  final DiscoverRecommendationItem item;
  final RateRecommendation onRate;

  @override
  State<_RecommendationButtons> createState() => __RecommendationButtonsState();
}

class __RecommendationButtonsState extends State<_RecommendationButtons> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Row(
      spacing: 5,
      mainAxisAlignment: .center,
      children: [
        IconButton(
          tooltip: 'Agree',
          icon: item.userRating == true
              ? Icon(
                  Icons.thumb_up,
                  size: Theming.iconSmall,
                  color: ColorScheme.of(context).primary,
                )
              : Icon(
                  Icons.thumb_up_outlined,
                  size: Theming.iconSmall,
                  color: ColorScheme.of(context).onSurface,
                ),
          onPressed: () async {
            final oldRating = item.rating;
            final oldUserRating = item.userRating;

            setState(() {
              switch (item.userRating) {
                case true:
                  item.rating--;
                  item.userRating = null;
                  break;
                case false:
                  item.rating += 2;
                  item.userRating = true;
                  break;
                case null:
                  item.rating++;
                  item.userRating = true;
                  break;
              }
            });

            final err = await widget.onRate(item.mediaId, item.recommendedMediaId, item.userRating);
            if (err == null) return;

            setState(() {
              item.rating = oldRating;
              item.userRating = oldUserRating;
            });

            if (context.mounted) {
              SnackBarExtension.show(context, err.toString());
            }
          },
        ),
        Text(item.rating.toString()),
        IconButton(
          tooltip: 'Disagree',
          icon: item.userRating == false
              ? Icon(
                  Icons.thumb_down,
                  size: Theming.iconSmall,
                  color: ColorScheme.of(context).error,
                )
              : Icon(
                  Icons.thumb_down_outlined,
                  size: Theming.iconSmall,
                  color: ColorScheme.of(context).onSurface,
                ),
          onPressed: () async {
            final oldRating = item.rating;
            final oldUserRating = item.userRating;

            setState(() {
              switch (item.userRating) {
                case true:
                  item.rating -= 2;
                  item.userRating = false;
                  break;
                case false:
                  item.rating++;
                  item.userRating = null;
                  break;
                case null:
                  item.rating--;
                  item.userRating = false;
                  break;
              }
            });

            final err = await widget.onRate(item.mediaId, item.recommendedMediaId, item.userRating);
            if (err == null) return;

            setState(() {
              item.rating = oldRating;
              item.userRating = oldUserRating;
            });

            if (context.mounted) {
              SnackBarExtension.show(context, err.toString());
            }
          },
        ),
      ],
    );
  }
}

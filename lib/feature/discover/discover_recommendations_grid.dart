import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

typedef OnRateRecommendation =
    Future<Object?> Function(int mediaId, int recommendedMediaId, bool? rating);

class DiscoverRecommendationsGrid extends StatelessWidget {
  const DiscoverRecommendationsGrid(this.items, {required this.onRate, required this.highContrast});

  final List<DiscoverRecommendationItem> items;
  final OnRateRecommendation onRate;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No items')));
    }

    final bodyMediumLineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final presentationHeight = bodyMediumLineHeight * 4 + 13;
    final ratingHeight = max(bodyMediumLineHeight, Theming.minTapTarget);
    final tileHeight = presentationHeight + ratingHeight;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 300, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => _Tile(items[i], onRate, highContrast, presentationHeight),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item, this.onRate, this.highContrast, this.presentationHeight);

  final DiscoverRecommendationItem item;
  final OnRateRecommendation onRate;
  final bool highContrast;
  final double presentationHeight;

  @override
  Widget build(BuildContext context) {
    final coverWidth = presentationHeight / Theming.coverHtoWRatio;

    return CardExtension.highContrast(highContrast)(
      child: Column(
        children: [
          SizedBox(
            height: presentationHeight,
            child: Row(
              children: [
                MediaRouteTile(
                  id: item.mediaId,
                  imageUrl: item.mediaCover,
                  child: ClipRRect(
                    borderRadius: Theming.borderRadiusSmall,
                    child: CachedImage(item.mediaCover, width: coverWidth),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const .symmetric(horizontal: Theming.offset, vertical: 5),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      mainAxisAlignment: .spaceAround,
                      children: [
                        GestureDetector(
                          behavior: .opaque,
                          onTap: () => context.push(Routes.media(item.mediaId, item.mediaCover)),
                          child: Text(item.mediaTitle, overflow: .ellipsis, maxLines: 2),
                        ),
                        const Divider(height: 3),
                        GestureDetector(
                          behavior: .opaque,
                          onTap: () => context.push(
                            Routes.media(item.recommendedMediaId, item.recommendedMediaCover),
                          ),
                          child: Text(
                            item.recommendedMediaTitle,
                            overflow: .ellipsis,
                            textAlign: .end,
                            maxLines: 2,
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
                    child: CachedImage(item.recommendedMediaCover, width: coverWidth),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: Theming.offset),
            child: Row(
              spacing: 5,
              children: [
                Expanded(
                  child: item.mediaListStatus == null
                      ? const SizedBox()
                      : Text(
                          item.mediaListStatus!,
                          textAlign: .left,
                          overflow: .ellipsis,
                          maxLines: 1,
                        ),
                ),
                _RecommendationButtons(item, onRate),
                Expanded(
                  child: item.recommendedMediaListStatus == null
                      ? const SizedBox()
                      : Text(
                          item.recommendedMediaListStatus!,
                          textAlign: .right,
                          overflow: .ellipsis,
                          maxLines: 1,
                        ),
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
  final OnRateRecommendation onRate;

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

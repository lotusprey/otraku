import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/widget/text_rail.dart';

class MediaRecommendationsSubview extends StatelessWidget {
  const MediaRecommendationsSubview({
    required this.id,
    required this.scrollCtrl,
    required this.rateRecommendation,
  });

  final int id;
  final ScrollController scrollCtrl;
  final Future<Object?> Function(int, bool?) rateRecommendation;

  @override
  Widget build(BuildContext context) {
    return PagedView<Recommendation>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaConnectionsProvider(id)),
      provider: mediaConnectionsProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.recommendations),
      ),
      onData: (data) => _MediaRecommendationsGrid(
        id,
        data.items,
        rateRecommendation,
      ),
    );
  }
}

class _MediaRecommendationsGrid extends StatelessWidget {
  const _MediaRecommendationsGrid(
    this.mediaId,
    this.items,
    this.rateRecommendation,
  );

  final int mediaId;
  final List<Recommendation> items;
  final Future<Object?> Function(int, bool?) rateRecommendation;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No results')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 270,
        height: 100,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) {
          final textRailItems = <String, bool>{
            if (items[i].entryStatus != null)
              items[i].entryStatus!.label(items[i].isAnime): true,
            if (items[i].format != null) items[i].format!.label: false,
            if (items[i].releaseYear != null)
              items[i].releaseYear!.toString(): false,
          };

          return Card(
            child: MediaRouteTile(
              id: items[i].id,
              imageUrl: items[i].imageUrl,
              child: Row(
                children: [
                  Hero(
                    tag: items[i].id,
                    child: ClipRRect(
                      borderRadius: Theming.borderRadiusSmall,
                      child: Container(
                        color: ColorScheme.of(context).surfaceContainerHighest,
                        child: CachedImage(
                          items[i].imageUrl,
                          width: 100 / Theming.coverHtoWRatio,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: Theming.paddingAll,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: Text(
                              items[i].title,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextRail(
                                textRailItems,
                                style: TextTheme.of(context).labelMedium,
                                maxLines: 2,
                              ),
                              _RecommendationRating(
                                mediaId,
                                items[i],
                                rateRecommendation,
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
        },
      ),
    );
  }
}

class _RecommendationRating extends StatefulWidget {
  const _RecommendationRating(this.mediaId, this.item, this.rateRecommendation);

  final int mediaId;
  final Recommendation item;
  final Future<Object?> Function(int, bool?) rateRecommendation;

  @override
  State<_RecommendationRating> createState() => _RecommendationRatingState();
}

class _RecommendationRatingState extends State<_RecommendationRating> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Row(
      spacing: Theming.offset,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: 'Agree',
          child: InkResponse(
            onTap: () async {
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

              final err = await widget.rateRecommendation(
                item.id,
                item.userRating,
              );
              if (err == null) return;

              setState(() {
                item.rating = oldRating;
                item.userRating = oldUserRating;
              });

              if (context.mounted) {
                SnackBarExtension.show(context, err.toString());
              }
            },
            child: item.userRating == true
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
          ),
        ),
        Text(item.rating.toString()),
        Tooltip(
          message: 'Disagree',
          child: InkResponse(
            onTap: () async {
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

              final err = await widget.rateRecommendation(
                item.id,
                item.userRating,
              );
              if (err == null) return;

              setState(() {
                item.rating = oldRating;
                item.userRating = oldUserRating;
              });

              if (context.mounted) {
                SnackBarExtension.show(context, err.toString());
              }
            },
            child: item.userRating == false
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
          ),
        ),
      ],
    );
  }
}

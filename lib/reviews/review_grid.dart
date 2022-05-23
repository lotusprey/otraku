import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/reviews/reviews.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';

class ReviewGrid extends StatelessWidget {
  ReviewGrid(this.items);

  final List<ReviewItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: Consts.padding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 270,
          height: 200,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(items[i]),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  _Tile(this.item);

  final ReviewItem item;

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      id: item.id,
      text: item.bannerUrl,
      explorable: Explorable.review,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.borderRadiusMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.bannerUrl != null)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Consts.radiusMin),
                  child: Hero(
                    tag: item.id,
                    child: FadeImage(item.bannerUrl!),
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: Consts.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Review of ${item.mediaTitle} by ${item.userName}',
                          style: Theme.of(context).textTheme.headline2,
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
                              style: Theme.of(context).textTheme.subtitle1,
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
                                Icon(
                                  Icons.thumbs_up_down_outlined,
                                  size: Consts.iconSmall,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.rating,
                                  style: Theme.of(context).textTheme.subtitle1,
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

class ReviewGridOld extends StatelessWidget {
  ReviewGridOld({required this.items});

  final List<ExplorableModel> items;

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > Consts.layoutBig
        ? (MediaQuery.of(context).size.width - Consts.layoutBig) / 2
        : 10.0;

    return SliverPadding(
      padding: EdgeInsets.only(left: sidePadding, right: sidePadding, top: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 270,
          height: 200,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _TileOld(items[i]),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _TileOld extends StatelessWidget {
  final ExplorableModel model;
  _TileOld(this.model);

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      id: model.id,
      text: model.imageUrl,
      explorable: Explorable.review,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.borderRadiusMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (model.imageUrl != null)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Consts.radiusMin),
                  child: Hero(
                    tag: model.id,
                    child: FadeImage(model.imageUrl!),
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: Consts.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          model.text1,
                          style: Theme.of(context).textTheme.headline2,
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
                              model.text2!,
                              style: Theme.of(context).textTheme.subtitle1,
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
                                Icon(
                                  Icons.thumbs_up_down_outlined,
                                  size: Consts.iconSmall,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  model.text3!,
                                  style: Theme.of(context).textTheme.subtitle1,
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

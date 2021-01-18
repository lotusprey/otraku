import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/tile_data.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/layouts/custom_grid_delegate.dart';

class ReviewGrid extends StatelessWidget {
  final List<TileData> results;
  final Function loadMore;

  ReviewGrid(this.results, this.loadMore);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == results.length - 6) loadMore();

            return BrowseIndexer(
              id: results[index].id,
              imageUrl: results[index].imageUrl,
              browsable: Browsable.review,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: Config.BORDER_RADIUS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (results[index].imageUrl != null)
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Config.RADIUS),
                          child: Hero(
                            tag: results[index].imageUrl,
                            child: FadeInImage.memoryNetwork(
                              placeholder: FnHelper.transparentImage,
                              image: results[index].imageUrl,
                              fadeInDuration: Config.FADE_DURATION,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: Config.PADDING,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  results[index].title,
                                  style: Theme.of(context).textTheme.headline6,
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
                                      results[index].subtitle,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Icon(
                                      Icons.thumb_up_outlined,
                                      size: Styles.ICON_SMALL,
                                    ),
                                  ),
                                  Text(
                                    results[index].caption,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
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
          },
          childCount: results.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
          minWidth: 300,
          height: 200,
        ),
      ),
    );
  }
}

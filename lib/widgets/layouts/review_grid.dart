import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';

class ReviewGrid extends StatelessWidget {
  final List<BrowseResultModel> results;
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
                            tag: results[index].id,
                            child: FadeImage(results[index].imageUrl),
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
                                  results[index].text1,
                                  style: Theme.of(context).textTheme.headline5,
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
                                      results[index].text2!,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Icon(
                                      Icons.thumb_up_outlined,
                                      size: Style.ICON_SMALL,
                                    ),
                                  ),
                                  Text(
                                    results[index].text3!,
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
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 300,
          height: 200,
        ),
      ),
    );
  }
}

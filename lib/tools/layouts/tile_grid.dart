import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/models/browse_result_model.dart';
import 'package:otraku/models/tile_model.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/layouts/sliver_grid_delegates.dart';

class TileGrid extends StatelessWidget {
  final List<BrowseResultModel> tileData;
  final Function loadMore;
  final TileModel tileModel;

  TileGrid({
    @required this.tileData,
    @required this.loadMore,
    @required this.tileModel,
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              if (index == tileData.length - 6) loadMore?.call();

              return BrowseIndexer(
                browsable: tileData[index].browsable,
                id: tileData[index].id,
                imageUrl: tileData[index].imageUrl,
                child: Column(
                  children: [
                    Expanded(
                      child: Hero(
                        tag: tileData[index].id,
                        child: ClipRRect(
                          borderRadius: Config.BORDER_RADIUS,
                          child: Container(
                            color: tileModel.needsBackground
                                ? Theme.of(context).primaryColor
                                : null,
                            child: FadeImage(
                              tileData[index].imageUrl,
                              fit: tileModel.fit,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: tileModel.textHeight,
                      child: Text(
                        tileData[index].text1,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: tileData.length,
          ),
          gridDelegate: SliverGridDelegateWithMaxWidthAndAddedHeight(
            maxWidth: tileModel.maxWidth,
            additionalHeight: tileModel.textHeight,
            rawWHRatio: tileModel.imgWHRatio,
          ),
        ),
      );
}

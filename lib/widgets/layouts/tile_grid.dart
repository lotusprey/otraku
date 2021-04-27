import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/models/helper_models/tile_model.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';

class TileGrid extends StatelessWidget {
  final List<BrowseResultModel> tileData;
  final TileModel tileModel;
  final bool sliver;
  final ScrollController? scrollCtrl;

  TileGrid({
    required this.tileData,
    required this.tileModel,
    this.sliver = false,
    this.scrollCtrl,
    UniqueKey? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > 620
        ? (MediaQuery.of(context).size.width - 600) / 2.0
        : 10.0;
    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      top: 15,
    );

    if (!sliver)
      return GridView.builder(
        padding: padding,
        controller: scrollCtrl,
        physics: Config.PHYSICS,
        itemCount: tileData.length,
        itemBuilder: (_, i) => _Tile(tileData[i], tileModel),
        gridDelegate: SliverGridDelegateWithMaxWidthAndAddedHeight(
          maxWidth: tileModel.maxWidth,
          additionalHeight: tileModel.textHeight,
          rawWHRatio: tileModel.imgWHRatio,
        ),
      );

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(tileData[i], tileModel),
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
}

class _Tile extends StatelessWidget {
  final BrowseResultModel data;
  final TileModel tileModel;
  _Tile(this.data, this.tileModel);

  @override
  Widget build(BuildContext context) {
    return BrowseIndexer(
      browsable: data.browsable,
      id: data.id,
      imageUrl: data.imageUrl,
      child: Column(
        children: [
          Expanded(
            child: Hero(
              tag: data.id,
              child: ClipRRect(
                borderRadius: Config.BORDER_RADIUS,
                child: Container(
                  color: tileModel.needsBackground
                      ? Theme.of(context).primaryColor
                      : null,
                  child: FadeImage(
                    data.imageUrl,
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
              data.text1,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );
  }
}

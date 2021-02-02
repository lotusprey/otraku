import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/models/tile_data.dart';
import 'package:otraku/models/tile_config.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/layouts/browse_tile.dart';
import 'package:otraku/tools/layouts/custom_grid_delegate.dart';

class TileGrid extends StatelessWidget {
  final List<TileData> tileData;
  final Function loadMore;
  final TileConfig tile;

  TileGrid({
    @required this.tileData,
    @required this.loadMore,
    @required this.tile,
  });

  @override
  Widget build(BuildContext context) {
    final preferIdTag = tileData[0].browsable == Browsable.user;

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == tileData.length - 6) loadMore();

            return BrowseIndexer(
              browsable: tileData[index].browsable,
              id: tileData[index].id,
              imageUrl: tileData[index].imageUrl,
              child: BrowseTile(
                id: tileData[index].id,
                text: tileData[index].title,
                imageUrl: tileData[index].imageUrl,
                tile: tile,
                preferIdTag: preferIdTag,
              ),
            );
          },
          childCount: tileData.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
          minWidth: tile.width,
          height: tile.fullHeight,
        ),
      ),
    );
  }
}

class TitleList extends StatelessWidget {
  final List<TileData> results;
  final Function loadMore;

  TitleList(this.results, this.loadMore);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == results.length - 6) loadMore();

            return BrowseIndexer(
              browsable: results[index].browsable,
              id: results[index].id,
              imageUrl: results[index].title,
              child: Hero(
                tag: results[index].title,
                child: Container(
                  child: Text(
                    results[index].title,
                    style: Theme.of(context).textTheme.headline3,
                    maxLines: 2,
                  ),
                ),
              ),
            );
          },
          childCount: results.length,
        ),
        itemExtent: 60,
      ),
    );
  }
}

class NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          'No results',
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
    );
  }
}

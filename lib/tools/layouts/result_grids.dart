import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/tile_config.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/layouts/browse_tile.dart';

class TileGrid extends StatelessWidget {
  final List<BrowseResult> results;
  final Function loadMore;
  final TileConfig tile;

  TileGrid({
    @required this.results,
    @required this.loadMore,
    @required this.tile,
  });

  @override
  Widget build(BuildContext context) {
    final preferIdTag = results[0].browsable == Browsable.user;

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == results.length - 6) loadMore();

            return BrowseIndexer(
              browsable: results[index].browsable,
              id: results[index].id,
              tag: results[index].imageUrl,
              child: BrowseTile(
                id: results[index].id,
                text: results[index].title,
                imageUrl: results[index].imageUrl,
                tile: tile,
                preferIdTag: preferIdTag,
              ),
            );
          },
          childCount: results.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: tile.width,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: tile.width / tile.fullHeight,
        ),
      ),
    );
  }
}

class TitleList extends StatelessWidget {
  final List<BrowseResult> results;
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
              tag: results[index].title,
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

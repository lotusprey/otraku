import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/tools/layouts/large_grid_tile.dart';

class LargeGrid extends StatelessWidget {
  final List<BrowseResult> results;
  final Function loadMore;

  LargeGrid(this.results, this.loadMore);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == results.length - 6) loadMore();

            return MediaIndexer(
              itemType: results[index].browsable,
              id: results[index].id,
              tag: results[index].imageUrl,
              child: LargeGridTile(
                mediaId: results[index].id,
                text: results[index].title,
                imageUrl: results[index].imageUrl,
              ),
            );
          },
          childCount: results.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: Config.tileConfig.tileWidth,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: Config.tileConfig.tileWHRatio,
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

            return MediaIndexer(
              itemType: results[index].browsable,
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

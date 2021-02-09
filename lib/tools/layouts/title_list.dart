import 'package:flutter/material.dart';
import 'package:otraku/models/tile_data.dart';
import 'package:otraku/tools/browse_indexer.dart';

class TitleList extends StatelessWidget {
  final List<TileData> results;
  final Function loadMore;

  TitleList(this.results, this.loadMore);

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        sliver: SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              if (index == results.length - 6) loadMore?.call();

              return BrowseIndexer(
                browsable: results[index].browsable,
                id: results[index].id,
                imageUrl: results[index].title,
                child: Hero(
                  tag: results[index].id,
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

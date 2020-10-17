import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/tools/multichild_layouts/custom_grid_tile.dart';
import 'package:provider/provider.dart';

class ExploreGrid extends StatelessWidget {
  void _loadMore(BuildContext context) {
    if (Provider.of<Explorable>(context, listen: false).hasNextPage &&
        !Provider.of<Explorable>(context, listen: false).isLoading) {
      Provider.of<Explorable>(context, listen: false).addPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = Provider.of<Explorable>(context).results;

    if (results.length == 0) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No results',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );
    }

    if (results[0].browsable == Browsable.studios) {
      return SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        sliver: SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              if (index == results.length - 6) _loadMore(context);

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

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == results.length - 6) _loadMore(context);

            return MediaIndexer(
              itemType: results[index].browsable,
              id: results[index].id,
              tag: results[index].imageUrl,
              child: CustomGridTile(
                mediaId: results[index].id,
                text: results[index].title,
                imageUrl: results[index].imageUrl,
              ),
            );
          },
          childCount: results.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: ViewConfig.tileConfiguration.tileWidth,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: ViewConfig.tileConfiguration.tileWHRatio,
        ),
      ),
    );
  }
}

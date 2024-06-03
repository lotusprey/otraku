import 'package:flutter/material.dart';
import 'package:otraku/model/tile_item.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/link_tile.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grids/sliver_grid_delegates.dart';

class TileItemGrid extends StatelessWidget {
  const TileItemGrid(this.items);

  final List<TileItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No Media')));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 40,
        rawHWRatio: Theming.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (_, i) => LinkTile(
          id: items[i].id,
          info: items[i].imageUrl,
          discoverType: items[i].type,
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: items[i].id,
                  child: ClipRRect(
                    borderRadius: Theming.borderRadiusSmall,
                    child: Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: CachedImage(items[i].imageUrl),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 35,
                child: Text(
                  items[i].title,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

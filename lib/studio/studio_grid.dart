import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';

class StudioGrid extends StatelessWidget {
  StudioGrid(this.items);

  final List<StudioItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: Consts.padding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 230,
          height: 50,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: items.length,
          (_, i) => ExploreIndexer(
            id: items[i].id,
            text: items[i].name,
            explorable: Explorable.studio,
            child: Hero(
              tag: items[i].id,
              child: Text(
                items[i].name,
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

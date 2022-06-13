import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class TileGrid extends StatelessWidget {
  final List<ExplorableModel> models;
  final bool full;
  final ScrollController? scrollCtrl;

  TileGrid({
    required this.models,
    this.full = true,
    this.scrollCtrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > Consts.layoutBig
        ? (MediaQuery.of(context).size.width - Consts.layoutBig) / 2
        : 10.0;

    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      bottom: scrollCtrl == null ? 0 : NavLayout.offset(context),
      top: 10,
    );

    final gridDelegate = SliverGridDelegateWithMinWidthAndExtraHeight(
      minWidth: 100,
      extraHeight: 40,
      rawHWRatio: full ? Consts.coverHtoWRatio : 1.0,
    );

    if (scrollCtrl != null)
      return GridView.builder(
        padding: padding,
        controller: scrollCtrl,
        physics: Consts.physics,
        itemCount: models.length,
        gridDelegate: gridDelegate,
        itemBuilder: (_, i) => _Tile(models[i], full),
      );

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(models[i], full),
          childCount: models.length,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final ExplorableModel data;
  final bool full;

  _Tile(this.data, this.full);

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      explorable: data.explorable,
      id: data.id,
      text: data.imageUrl,
      child: Column(
        children: [
          Expanded(
            child: Hero(
              tag: data.id,
              child: ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: Container(
                  color: full ? Theme.of(context).colorScheme.surface : null,
                  child: FadeImage(
                    data.imageUrl!,
                    fit: full ? BoxFit.cover : BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 35,
            child: Text(
              data.text1,
              overflow: TextOverflow.fade,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}

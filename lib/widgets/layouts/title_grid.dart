import 'package:flutter/material.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class TitleGrid extends StatelessWidget {
  final List<ExplorableModel> results;
  final ScrollController? scrollCtrl;

  TitleGrid(this.results, {this.scrollCtrl, UniqueKey? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sidePadding =
        MediaQuery.of(context).size.width > Consts.LAYOUT_WIDE + 20
            ? (MediaQuery.of(context).size.width - Consts.LAYOUT_WIDE) / 2.0
            : 10.0;
    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      bottom: scrollCtrl == null ? 0 : NavLayout.offset(context),
      top: 15,
    );
    const gridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 230,
      height: 50,
    );

    if (scrollCtrl != null)
      return GridView.builder(
        padding: padding,
        controller: scrollCtrl,
        physics: Consts.PHYSICS,
        itemCount: results.length,
        gridDelegate: gridDelegate,
        itemBuilder: (_, i) => _Tile(results[i]),
      );

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(results[i]),
          childCount: results.length,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final ExplorableModel data;
  _Tile(this.data);

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      explorable: data.explorable,
      id: data.id,
      imageUrl: data.text1,
      child: Hero(
        tag: data.id,
        child: Text(
          data.text1,
          style: Theme.of(context).textTheme.headline1,
          overflow: TextOverflow.fade,
          maxLines: 2,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:otraku/models/discover_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class TitleGrid extends StatelessWidget {
  final List<DiscoverModel> results;
  final ScrollController? scrollCtrl;

  TitleGrid(this.results, {this.scrollCtrl, super.key});

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

    const gridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 230,
      height: 50,
    );

    if (scrollCtrl != null)
      return GridView.builder(
        padding: padding,
        controller: scrollCtrl,
        physics: Consts.physics,
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
  final DiscoverModel data;
  _Tile(this.data);

  @override
  Widget build(BuildContext context) {
    return LinkTile(
      discoverType: data.discoverType,
      id: data.id,
      text: data.text1,
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

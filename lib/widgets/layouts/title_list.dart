import 'package:flutter/material.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class TitleList extends StatelessWidget {
  final List<BrowseResultModel> results;
  final ScrollController? scrollCtrl;

  TitleList(this.results, {this.scrollCtrl, UniqueKey? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > 620
        ? (MediaQuery.of(context).size.width - 600) / 2.0
        : 10.0;
    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      bottom: scrollCtrl == null ? 0 : NavBar.offset(context),
      top: 15,
    );

    if (scrollCtrl != null)
      return ListView.builder(
        padding: padding,
        controller: scrollCtrl,
        physics: Config.PHYSICS,
        itemExtent: 60,
        itemCount: results.length,
        itemBuilder: (_, i) => _Tile(results[i]),
      );

    return SliverPadding(
      padding: padding,
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(results[i]),
          childCount: results.length,
        ),
        itemExtent: 60,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final BrowseResultModel data;
  _Tile(this.data);

  @override
  Widget build(BuildContext context) {
    return BrowseIndexer(
      browsable: data.browsable,
      id: data.id,
      imageUrl: data.text1,
      child: Hero(
        tag: data.id,
        child: Text(
          data.text1,
          style: Theme.of(context).textTheme.headline2,
          maxLines: 2,
        ),
      ),
    );
  }
}

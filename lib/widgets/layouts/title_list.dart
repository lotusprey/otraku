import 'package:flutter/material.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/browse_indexer.dart';

class TitleList extends StatelessWidget {
  final List<BrowseResultModel> results;
  final ScrollController? scrollCtrl;
  final bool sliver;

  TitleList(this.results, {this.sliver = true, this.scrollCtrl, UniqueKey? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sliver)
      return SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        sliver: SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _Tile(results[i]),
            childCount: results.length,
          ),
          itemExtent: 60,
        ),
      );

    return ListView.builder(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      controller: scrollCtrl,
      physics: Config.PHYSICS,
      itemExtent: 60,
      itemCount: results.length,
      itemBuilder: (_, i) => _Tile(results[i]),
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

import 'package:flutter/material.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/widgets/browse_indexer.dart';

class TitleList extends StatelessWidget {
  final List<BrowseResultModel> results;

  TitleList(this.results);

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        sliver: SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (_, index) => BrowseIndexer(
              browsable: results[index].browsable,
              id: results[index].id,
              imageUrl: results[index].text1,
              child: Hero(
                tag: results[index].id,
                child: Container(
                  child: Text(
                    results[index].text1,
                    style: Theme.of(context).textTheme.headline3,
                    maxLines: 2,
                  ),
                ),
              ),
            ),
            childCount: results.length,
          ),
          itemExtent: 60,
        ),
      );
}

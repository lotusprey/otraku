import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class ReviewGrid extends StatelessWidget {
  final List<BrowseResultModel> data;
  final ScrollController? scrollCtrl;

  ReviewGrid(this.data, {this.scrollCtrl});

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
      return GridView.builder(
        padding: padding,
        controller: scrollCtrl,
        physics: Config.PHYSICS,
        itemCount: data.length,
        itemBuilder: (_, i) => _Tile(data[i]),
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 200,
          height: 200,
        ),
      );

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(data[i]),
          childCount: data.length,
        ),
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 200,
          height: 200,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final BrowseResultModel model;
  _Tile(this.model);

  @override
  Widget build(BuildContext context) {
    return BrowseIndexer(
      id: model.id,
      imageUrl: model.imageUrl,
      browsable: Browsable.review,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: Config.BORDER_RADIUS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (model.imageUrl != null)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Config.RADIUS),
                  child: Hero(
                    tag: model.id,
                    child: FadeImage(model.imageUrl),
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: Config.PADDING,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          model.text1,
                          style: Theme.of(context).textTheme.headline5,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              model.text2!,
                              style: Theme.of(context).textTheme.subtitle1,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.thumbs_up_down_outlined,
                                  size: Style.ICON_SMALL,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  model.text3!,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class ReviewGrid extends StatelessWidget {
  final List<ExplorableModel> data;
  final ScrollController? scrollCtrl;

  ReviewGrid(this.data, {this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    final sidePadding = 10.0 +
        (MediaQuery.of(context).size.width > Consts.OVERLAY_WIDE
            ? (MediaQuery.of(context).size.width - Consts.OVERLAY_WIDE) / 2
            : 0.0);

    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      bottom: scrollCtrl == null ? 0 : NavLayout.offset(context),
      top: 15,
    );

    const gridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 270,
      height: 200,
    );

    if (scrollCtrl != null)
      return GridView.builder(
        padding: padding,
        controller: scrollCtrl,
        physics: Consts.PHYSICS,
        itemCount: data.length,
        gridDelegate: gridDelegate,
        itemBuilder: (_, i) => _Tile(data[i]),
      );

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(data[i]),
          childCount: data.length,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final ExplorableModel model;
  _Tile(this.model);

  @override
  Widget build(BuildContext context) {
    return ExploreIndexer(
      id: model.id,
      imageUrl: model.imageUrl,
      explorable: Explorable.review,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.BORDER_RADIUS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (model.imageUrl != null)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Consts.RADIUS),
                  child: Hero(
                    tag: model.id,
                    child: FadeImage(model.imageUrl!),
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: Consts.PADDING,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          model.text1,
                          style: Theme.of(context).textTheme.headline2,
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
                                  size: Consts.ICON_SMALL,
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

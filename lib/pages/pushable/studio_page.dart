import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/anilist/studio_data.dart';
import 'package:otraku/tools/layouts/custom_grid_delegate.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/layouts/result_grids.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/layouts/browse_tile.dart';
import 'package:otraku/tools/overlays/sort_sheet.dart';

class StudioPage extends StatelessWidget {
  final int id;
  final String textTag;

  StudioPage(this.id, this.textTag);

  @override
  Widget build(BuildContext context) {
    final studio = Get.find<Studio>(tag: id.toString());
    double extentOnLastCall = 0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => NotificationListener(
            onNotification: (notification) {
              if (studio.media.hasNextPage &&
                  notification is ScrollNotification &&
                  notification.metrics.extentAfter <= 50 &&
                  notification.metrics.maxScrollExtent > extentOnLastCall) {
                extentOnLastCall = notification.metrics.maxScrollExtent;
                studio.fetchPage();
              }
              return false;
            },
            child: CustomScrollView(
              physics: Config.PHYSICS,
              semanticChildCount:
                  studio.media != null ? studio.media.mediaCount : null,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StudioHeader(
                    studio.company,
                    textTag,
                    studio.toggleFavourite,
                  ),
                ),
                if (studio.company != null) ...[
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            FluentSystemIcons.ic_fluent_arrow_sort_filled,
                          ),
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (_) => MediaSortSheet(
                              studio.sort,
                              (sort) => studio.sort = sort,
                            ),
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (studio.sort == MediaSort.START_DATE ||
                      studio.sort == MediaSort.START_DATE_DESC ||
                      studio.sort == MediaSort.END_DATE ||
                      studio.sort == MediaSort.END_DATE_DESC) ...[
                    for (int i = 0;
                        i < studio.media.categories.length;
                        i++) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: Config.PADDING,
                          child: Text(
                            studio.media.categories[i],
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: Config.PADDING,
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, index) => BrowseIndexer(
                              browsable: Browsable.anime,
                              id: studio.media.split[i][index].id,
                              imageUrl: studio.media.split[i][index].imageUrl,
                              child: BrowseTile(
                                id: studio.media.split[i][index].id,
                                text: studio.media.split[i][index].title,
                                imageUrl: studio.media.split[i][index].imageUrl,
                                tile: Config.highTile,
                              ),
                            ),
                            childCount: studio.media.split[i].length,
                            semanticIndexOffset:
                                i * studio.media.split[i].length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithMinWidthAndFixedHeight(
                            minWidth: Config.highTile.width,
                            height: Config.highTile.fullHeight,
                          ),
                        ),
                      ),
                    ],
                  ] else
                    TileGrid(
                      tileData: studio.media.joined,
                      loadMore: studio.fetchPage,
                      tile: Config.highTile,
                    ),
                  if (studio.media != null && studio.media.hasNextPage)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: const Loader(),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).viewPadding.bottom,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudioHeader implements SliverPersistentHeaderDelegate {
  final StudioData company;
  final String textTag;
  final Future<bool> Function() toggleFavourite;

  _StudioHeader(this.company, this.textTag, this.toggleFavourite);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercentage = shrinkOffset / (maxExtent - minExtent);

    return Container(
      height: maxExtent,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Align(
              alignment: Alignment.center,
              child: Hero(
                tag: textTag,
                child: Text(
                  textTag,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).dividerColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                if (company != null)
                  FavoriteButton(
                    favourites: company.favourites,
                    isFavourite: company.isFavourite,
                    shrinkPercentage: shrinkPercentage,
                    toggle: toggleFavourite,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/anilist/person_model.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/layouts/tile_grid.dart';
import 'package:otraku/tools/overlays/sheets.dart';

class StudioPage extends StatelessWidget {
  static const ROUTE = '/studio';

  final int id;
  final String name;

  StudioPage(this.id, this.name);

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
                    id,
                    name,
                    studio.toggleFavourite,
                  ),
                ),
                if (studio.company != null) ...[
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Sort',
                          icon: const Icon(
                            FluentSystemIcons.ic_fluent_arrow_sort_filled,
                          ),
                          onPressed: () => Sheet.show(
                            ctx: context,
                            sheet: MediaSortSheet(
                              studio.sort,
                              (sort) => studio.sort = sort,
                            ),
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
                      TileGrid(
                        tileData: studio.media.split[i],
                        tileModel: Config.highTile,
                        loadMore: null,
                      ),
                    ],
                  ] else
                    TileGrid(
                      tileData: studio.media.joined,
                      loadMore: studio.fetchPage,
                      tileModel: Config.highTile,
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
  final PersonModel company;
  final int companyId;
  final String name;
  final Future<bool> Function() toggleFavourite;

  _StudioHeader(this.company, this.companyId, this.name, this.toggleFavourite);

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
                tag: companyId,
                child: Text(
                  name,
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
                  tooltip: 'Close',
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

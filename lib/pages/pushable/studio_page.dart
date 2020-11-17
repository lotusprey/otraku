import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/controllers/app_config.dart';
import 'package:otraku/models/page_data/page_entry.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/tools/layouts/custom_grid_tile.dart';
import 'package:otraku/tools/overlays/media_sort_sheet.dart';

class StudioPage extends StatelessWidget {
  final int id;
  final String textTag;

  StudioPage(this.id, this.textTag);

  @override
  Widget build(BuildContext context) {
    double extentOnLastCall = 0;

    return Scaffold(
      body: SafeArea(
        child: GetX<Studio>(
          init: Studio(),
          initState: (_) => Get.find<Studio>().fetchStudio(id),
          builder: (studio) {
            return NotificationListener(
              onNotification: (notification) {
                if (studio.groups.hasNextPage &&
                    notification is ScrollNotification &&
                    notification.metrics.extentAfter <= 50 &&
                    notification.metrics.maxScrollExtent > extentOnLastCall) {
                  extentOnLastCall = notification.metrics.maxScrollExtent;
                  studio.fetchPage();
                }
                return false;
              },
              child: _OrderedGroups(studio, textTag),
            );
          },
        ),
      ),
    );
  }
}

class _OrderedGroups extends StatelessWidget {
  final Studio studio;
  final String textTag;

  _OrderedGroups(this.studio, this.textTag);

  @override
  Widget build(BuildContext context) {
    final groups = studio.groups;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      semanticChildCount: groups != null ? groups.mediaCount : null,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _StudioHeader(studio.company, textTag),
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
                    builder: (ctx) => MediaSortSheet(),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < groups.categories.length; i++) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: AppConfig.PADDING,
                child: Text(
                  groups.categories[i],
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
            SliverPadding(
              padding: AppConfig.PADDING,
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, index) => MediaIndexer(
                    itemType: Browsable.anime,
                    id: groups.media[i][index].id,
                    tag: groups.media[i][index].imageUrl,
                    child: CustomGridTile(
                      mediaId: groups.media[i][index].id,
                      text: groups.media[i][index].title,
                      imageUrl: groups.media[i][index].imageUrl,
                    ),
                  ),
                  childCount: groups.media[i].length,
                  semanticIndexOffset: i * groups.media[i].length,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: AppConfig.tileConfig.tileWidth,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: AppConfig.tileConfig.tileWHRatio,
                ),
              ),
            ),
          ],
          if (groups != null && groups.hasNextPage)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: const BlossomLoader(),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StudioHeader implements SliverPersistentHeaderDelegate {
  final PageEntry company;
  final String textTag;

  _StudioHeader(this.company, this.textTag);

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
            padding: const EdgeInsets.symmetric(horizontal: 50),
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
                if (company != null) FavoriteButton(company, shrinkPercentage)
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 140;

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

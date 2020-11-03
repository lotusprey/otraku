import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/page_data/studio.dart';
import 'package:otraku/providers/page_item.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/tools/multichild_layouts/custom_grid_tile.dart';

class StudioPage extends StatefulWidget {
  final int id;
  final String textTag;

  StudioPage(this.id, this.textTag);

  @override
  _StudioPageState createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  Studio _studio;
  double extentOnLastCall = 0;

  int counter = 0;
  bool _loadMore(Notification notification) {
    if (notification is ScrollNotification &&
        notification.metrics.extentAfter <= 50 &&
        notification.metrics.maxScrollExtent > extentOnLastCall) {
      extentOnLastCall = notification.metrics.maxScrollExtent;
      PageItem.fetchStudio(widget.id, _studio).then((_) => setState(() {}));
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: NotificationListener(
            onNotification: (notification) => _loadMore(notification),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StudioHeader(_studio, widget.textTag),
                ),
                if (_studio != null) ...[
                  for (int i = 0; i < _studio.media.item1.length; i++) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: AppConfig.PADDING,
                        child: Text(
                          _studio.media.item1[i],
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
                            id: _studio.media.item2[i][index].id,
                            tag: _studio.media.item2[i][index].imageUrl,
                            child: CustomGridTile(
                              mediaId: _studio.media.item2[i][index].id,
                              text: _studio.media.item2[i][index].title,
                              imageUrl: _studio.media.item2[i][index].imageUrl,
                            ),
                          ),
                          childCount: _studio.media.item2[i].length,
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child:
                            _studio.hasNextPage ? const BlossomLoader() : null,
                      ),
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

  @override
  void initState() {
    super.initState();
    PageItem.fetchStudio(widget.id, null).then((studio) {
      if (studio == null) return;
      setState(() => _studio = studio);
    });
  }
}

class _StudioHeader implements SliverPersistentHeaderDelegate {
  final Studio studio;
  final String textTag;

  _StudioHeader(this.studio, this.textTag);

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
                if (studio != null) FavoriteButton(studio, shrinkPercentage)
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

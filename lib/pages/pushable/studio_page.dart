import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/page_data/studio_data.dart';
import 'package:otraku/providers/page_item.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:provider/provider.dart';

class StudioPage extends StatefulWidget {
  final int id;
  final String name;
  final Object tag;

  StudioPage(this.id, this.tag, this.name);

  @override
  _StudioPageState createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  StudioData _studio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _Header(_studio, widget.tag, widget.name),
              ),
              SliverToBoxAdapter(child: Container(height: 800)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PageItem>(context, listen: false)
        .fetchStudio(widget.id)
        .then((studio) => setState(() => _studio = studio));
  }
}

class _Header implements SliverPersistentHeaderDelegate {
  final StudioData studio;
  final Object tag;
  final String title;

  _Header(this.studio, this.tag, this.title);

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
                tag: tag,
                child: Text(
                  title,
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
                studio != null
                    ? FavoriteButton(studio, shrinkPercentage)
                    : const SizedBox(),
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

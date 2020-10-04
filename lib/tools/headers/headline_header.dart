import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HeadlineHeader extends StatelessWidget {
  final String headline;

  const HeadlineHeader(this.headline);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      floating: false,
      delegate: _HeadlineHeaderDelegate(context: context, headline: headline),
    );
  }
}

class _HeadlineHeaderDelegate implements SliverPersistentHeaderDelegate {
  final String headline;
  double _height;

  _HeadlineHeaderDelegate({
    @required this.headline,
    @required BuildContext context,
  }) {
    _height = 40;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Text(
        headline,
        style: Theme.of(context).textTheme.headline1.copyWith(height: 1.0),
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  TickerProvider get vsync => null;
}

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HeadlineHeader extends StatelessWidget {
  final String headline;
  final bool isPushed;

  const HeadlineHeader(this.headline, this.isPushed);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        pinned: false,
        floating: false,
        delegate: _HeadlineHeaderDelegate(
          context: context,
          headline: headline,
          isPushed: isPushed,
        ),
      );
}

class _HeadlineHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 40.0;

  final String headline;
  final bool isPushed;

  _HeadlineHeaderDelegate({
    @required this.headline,
    @required this.isPushed,
    @required BuildContext context,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Row(
          children: [
            if (isPushed)
              IconButton(
                padding: const EdgeInsets.only(right: 20),
                icon: const Icon(FluentSystemIcons.ic_fluent_arrow_left_filled),
                onPressed: () => Navigator.pop(context),
              ),
            Text(headline, style: Theme.of(context).textTheme.headline3),
          ],
        ),
      );

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

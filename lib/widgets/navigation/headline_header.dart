import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HeadlineHeader extends StatelessWidget {
  final String headline;
  final bool canPop;

  const HeadlineHeader(this.headline, this.canPop);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        pinned: false,
        floating: false,
        delegate: _Delegate(
          context: context,
          headline: headline,
          canPop: canPop,
        ),
      );
}

class _Delegate implements SliverPersistentHeaderDelegate {
  final String headline;
  final bool canPop;

  _Delegate({
    required this.headline,
    required this.canPop,
    required BuildContext context,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canPop)
              IconButton(
                tooltip: 'Close',
                padding: const EdgeInsets.only(right: 20),
                icon: const Icon(FluentIcons.arrow_left_24_regular),
                onPressed: () => Navigator.pop(context),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                headline,
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  @override
  double get maxExtent => 30;

  @override
  double get minExtent => 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  TickerProvider? get vsync => null;
}

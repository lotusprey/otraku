import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/utils/config.dart';

class OpaqueHeader extends StatelessWidget {
  final List<Widget> children;
  OpaqueHeader(this.children);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _Delegate(children),
      pinned: true,
    );
  }
}

class _Delegate implements SliverPersistentHeaderDelegate {
  final List<Widget> children;
  _Delegate(this.children);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: Config.MATERIAL_TAP_TARGET_SIZE,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            offset: const Offset(0, 3),
            blurRadius: 7,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  @override
  double get maxExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  double get minExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}

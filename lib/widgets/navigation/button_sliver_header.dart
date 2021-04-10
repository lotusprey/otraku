import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/utils/config.dart';

class ButtonSliverHeader extends StatelessWidget {
  final Widget leading;
  final List<Widget> trailing;
  ButtonSliverHeader({required this.leading, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _Delegate(leading, trailing),
      pinned: true,
    );
  }
}

class _Delegate implements SliverPersistentHeaderDelegate {
  final Widget leading;
  final List<Widget> trailing;
  _Delegate(this.leading, this.trailing);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [leading, Row(children: trailing)],
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

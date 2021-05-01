import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/utils/config.dart';

class TransparentHeader extends StatelessWidget {
  final List<Widget> children;
  TransparentHeader(this.children) {
    if (children.length > 1) {
      const box = SizedBox(width: 15);
      for (int i = 1; i < children.length; i += 2) children.insert(i, box);
    }
  }

  @override
  Widget build(BuildContext context) =>
      SliverPersistentHeader(delegate: _Delegate(children), pinned: true);
}

class _Delegate implements SliverPersistentHeaderDelegate {
  static const _height = 50.0;

  final List<Widget> children;
  _Delegate(this.children);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: Config.filter,
        child: Container(
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).cardColor,
          child: Row(children: children),
        ),
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

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

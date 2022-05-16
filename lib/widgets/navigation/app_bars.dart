import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';

class ShadowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget> actions;

  const ShadowAppBar({
    this.title = '',
    this.titleWidget,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _ShadowBody([
        TopBarIcon(
          icon: Ionicons.chevron_back_outline,
          tooltip: 'Close',
          onTap: () => Navigator.pop(context),
        ),
        Expanded(
          child: titleWidget != null
              ? titleWidget!
              : Text(title, style: Theme.of(context).textTheme.headline1),
        ),
        ...actions,
      ]),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Consts.tapTargetSize);
}

class ShadowSliverAppBar extends StatelessWidget {
  const ShadowSliverAppBar(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: _ShadowSliverAppBarDelegate(children),
        pinned: true,
      );
}

class _ShadowSliverAppBarDelegate implements SliverPersistentHeaderDelegate {
  _ShadowSliverAppBarDelegate(this.children);

  final List<Widget> children;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      _ShadowBody(children);

  @override
  double get maxExtent => Consts.tapTargetSize;

  @override
  double get minExtent => Consts.tapTargetSize;

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

class _ShadowBody extends StatelessWidget {
  final List<Widget> children;
  const _ShadowBody(this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Consts.tapTargetSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 5,
            color: Theme.of(context).colorScheme.background,
          ),
        ],
      ),
      child: Row(children: children),
    );
  }
}

class TranslucentSliverAppBar extends StatelessWidget {
  const TranslucentSliverAppBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: _TranslucentAppBarDelegate(children),
        pinned: true,
      );
}

class _TranslucentAppBarDelegate implements SliverPersistentHeaderDelegate {
  _TranslucentAppBarDelegate(this.children);

  final List<Widget> children;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      ClipRect(
        child: BackdropFilter(
          filter: Consts.filter,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: Consts.tapTargetSize,
                  maxWidth: Consts.layoutBig,
                ),
                child: Row(children: children),
              ),
            ),
          ),
        ),
      );

  @override
  double get maxExtent => Consts.tapTargetSize;

  @override
  double get minExtent => Consts.tapTargetSize;

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

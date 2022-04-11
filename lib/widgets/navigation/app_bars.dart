import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';

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
        AppBarIcon(
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
  Size get preferredSize => Size.fromHeight(Consts.TAP_TARGET_SIZE);
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
  double get maxExtent => Consts.TAP_TARGET_SIZE;

  @override
  double get minExtent => Consts.TAP_TARGET_SIZE;

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
      height: Consts.TAP_TARGET_SIZE,
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
                  maxHeight: Consts.TAP_TARGET_SIZE,
                  maxWidth: Consts.LAYOUT_BIG,
                ),
                child: Row(children: children),
              ),
            ),
          ),
        ),
      );

  @override
  double get maxExtent => Consts.TAP_TARGET_SIZE;

  @override
  double get minExtent => Consts.TAP_TARGET_SIZE;

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

class AppBarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? colour;
  final void Function() onTap;

  const AppBarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onTap,
      iconSize: Consts.ICON_BIG,
      splashColor: Colors.transparent,
      color: colour ?? Theme.of(context).colorScheme.onBackground,
      constraints: const BoxConstraints(maxWidth: 45, maxHeight: 45),
      padding: Consts.PADDING,
    );
  }
}

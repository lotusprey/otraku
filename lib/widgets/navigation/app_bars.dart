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
  Size get preferredSize => Size.fromHeight(Consts.MATERIAL_TAP_TARGET_SIZE);
}

class SliverShadowAppBar extends StatelessWidget {
  final List<Widget> children;
  const SliverShadowAppBar(this.children);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: _SliverShadowAppBarDelegate(children),
        pinned: true,
      );
}

class _SliverShadowAppBarDelegate implements SliverPersistentHeaderDelegate {
  final List<Widget> children;
  _SliverShadowAppBarDelegate(this.children);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      _ShadowBody(children);

  @override
  double get maxExtent => Consts.MATERIAL_TAP_TARGET_SIZE;

  @override
  double get minExtent => Consts.MATERIAL_TAP_TARGET_SIZE;

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
      height: Consts.MATERIAL_TAP_TARGET_SIZE,
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

class SliverTransparentAppBar extends StatelessWidget {
  final List<Widget> children;
  const SliverTransparentAppBar(this.children);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: _SliverTransparentAppBarDelegate(children),
        pinned: true,
      );
}

class _SliverTransparentAppBarDelegate
    implements SliverPersistentHeaderDelegate {
  final List<Widget> children;
  _SliverTransparentAppBarDelegate(this.children);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      ClipRect(
        child: BackdropFilter(
          filter: Consts.filter,
          child: Container(
            height: Consts.MATERIAL_TAP_TARGET_SIZE,
            color: Theme.of(context).cardColor,
            child: Row(children: children),
          ),
        ),
      );

  @override
  double get maxExtent => Consts.MATERIAL_TAP_TARGET_SIZE;

  @override
  double get minExtent => Consts.MATERIAL_TAP_TARGET_SIZE;

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

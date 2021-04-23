import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/utils/config.dart';

class CustomSliverHeader extends StatelessWidget {
  final double height;
  final Widget? background;
  final Widget? child;
  final List<Widget>? actions;
  final String? title;
  final bool actionsScrollFadeIn;
  final bool titleScrollFadeIn;
  final bool implyLeading;

  CustomSliverHeader({
    required this.height,
    this.child,
    this.background,
    this.title,
    this.actions = const [],
    this.actionsScrollFadeIn = true,
    this.titleScrollFadeIn = true,
    this.implyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        height: height,
        background: background,
        child: child,
        actions: actions,
        title: title,
        actionsScrollFadeIn: actionsScrollFadeIn,
        titleScrollFadeIn: titleScrollFadeIn,
        implyLeading: implyLeading,
      ),
    );
  }
}

class _Delegate implements SliverPersistentHeaderDelegate {
  final double height;
  final Widget? background;
  final Widget? child;
  final List<Widget>? actions;
  final String? title;
  final bool actionsScrollFadeIn;
  final bool titleScrollFadeIn;
  final bool implyLeading;
  late double _middleExtent;

  _Delegate({
    required this.height,
    required this.background,
    required this.child,
    required this.actions,
    required this.title,
    required this.actionsScrollFadeIn,
    required this.titleScrollFadeIn,
    required this.implyLeading,
  }) {
    _middleExtent = (minExtent + maxExtent) * 0.5;
    if (actions != null && actions!.length > 1) {
      const box = SizedBox(width: 15);
      for (int i = 1; i < actions!.length; i += 2) actions!.insert(i, box);
    }
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final currentExtent = maxExtent - shrinkOffset;
    final titleOpacity = !titleScrollFadeIn || currentExtent <= minExtent
        ? 1.0
        : 1.0 - currentExtent / maxExtent;
    final actionOpacity = !actionsScrollFadeIn || currentExtent <= minExtent
        ? 1.0
        : 1.0 - currentExtent / maxExtent;
    final headerOpacity = currentExtent >= _middleExtent
        ? 0.0
        : currentExtent <= minExtent
            ? 1.0
            : 1.0 - (currentExtent - minExtent) / (_middleExtent - minExtent);

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: FlexibleSpaceBar.createSettings(
        minExtent: minExtent,
        maxExtent: maxExtent,
        currentExtent: currentExtent > minExtent ? currentExtent : minExtent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null)
              FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                stretchModes: [StretchMode.zoomBackground],
                background: background,
              ),
            if (child != null)
              Padding(
                padding:
                    const EdgeInsets.only(top: Config.MATERIAL_TAP_TARGET_SIZE),
                child: child,
              ),
            if (headerOpacity > 0.001)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .backgroundColor
                        .withAlpha((headerOpacity * 255).ceil()),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 10,
              right: 10,
              height: minExtent,
              child: Row(
                children: [
                  if (implyLeading)
                    IconShade(IconButton(
                      tooltip: 'Close',
                      padding: const EdgeInsets.all(0),
                      constraints:
                          const BoxConstraints(maxWidth: Style.ICON_BIG),
                      icon: const Icon(Icons.close),
                      color: Theme.of(context).dividerColor,
                      onPressed: () => Get.back(),
                    )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Opacity(
                        opacity: titleOpacity,
                        child: title != null
                            ? Text(
                                title!,
                                style: Theme.of(context).textTheme.headline5,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                  if (actions != null)
                    Opacity(
                      opacity: actionOpacity,
                      child: Row(children: actions!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get minExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  double get maxExtent => height;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(stretchTriggerOffset: 100);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}

class IconShade extends StatelessWidget {
  final IconButton iconButton;
  IconShade(this.iconButton);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 10,
            spreadRadius: -10,
          ),
        ],
      ),
      child: iconButton,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/drag_detector.dart';

/// Represents the top and bottom padding of a page.
class PageOffset {
  const PageOffset(this.top, this.bottom);

  final double top;
  final double bottom;

  /// Calculates the offsets needed to avoid the top/bottom bar
  /// overlays using the nearest [Scaffold] and [PageLayout].
  static PageOffset of(BuildContext context) {
    double topOffset = 0;
    double bottomOffset = 0;

    final scaffold = context.findAncestorStateOfType<ScaffoldState>();
    if (scaffold != null) {
      final padding = MediaQuery.of(scaffold.context).viewPadding;
      topOffset = padding.top;
      bottomOffset = padding.bottom;
    }

    final pageLayout = context.findAncestorWidgetOfExactType<PageLayout>();
    if (pageLayout?.topBar != null) topOffset += Consts.tapTargetSize;
    if (pageLayout?.bottomBar != null) bottomOffset += Consts.tapTargetSize;

    return PageOffset(topOffset, bottomOffset);
  }
}

class PageLayout extends StatelessWidget {
  const PageLayout({
    required this.builder,
    this.topBar,
    this.floatingBar,
    this.bottomBar,
  });

  final Widget Function(BuildContext, double, double) builder;
  final TopBar? topBar;
  final FloatingBar? floatingBar;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final content = builder(
      context,
      MediaQuery.of(context).viewPadding.top +
          (topBar == null ? 0 : Consts.tapTargetSize),
      MediaQuery.of(context).viewPadding.bottom +
          (bottomBar == null ? 0 : Consts.tapTargetSize),
    );

    return Scaffold(
      body: content,
      appBar: topBar,
      floatingActionButton: floatingBar,
      bottomNavigationBar: bottomBar != null ? _BottomBar(bottomBar!) : null,
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: Settings().leftHanded
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }
}

/// A top app bar implementation that uses a blurred, translucent background.
/// [items] are the widgets that will appear on the top of it. If [canPop]
/// is true, a button that can pop the page will be placed before [items].
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({this.items = const [], this.canPop = true, this.title});

  final bool canPop;
  final String? title;
  final List<Widget> items;

  @override
  Size get preferredSize => const Size.fromHeight(Consts.tapTargetSize);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: Consts.filter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
                child: Row(
                  children: [
                    if (canPop)
                      TopBarIcon(
                        tooltip: 'Close',
                        icon: Ionicons.chevron_back_outline,
                        onTap: () => Navigator.maybePop(context),
                      ),
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                    ...items,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An [IconButton] customised for a top app bar.
class TopBarIcon extends StatelessWidget {
  const TopBarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.colour,
  });

  final IconData icon;
  final String tooltip;
  final Color? colour;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onTap,
      iconSize: Consts.iconBig,
      splashColor: Colors.transparent,
      color: colour ?? Theme.of(context).colorScheme.onBackground,
      constraints: const BoxConstraints(maxWidth: 45, maxHeight: 45),
      padding: Consts.padding,
    );
  }
}

/// Hides the [child] on scroll-down and reveals it on scroll-up.
class FloatingBar extends StatefulWidget {
  FloatingBar({required this.child, required this.scrollCtrl});

  final Widget child;
  final ScrollController scrollCtrl;

  @override
  _FloatingBarState createState() => _FloatingBarState();
}

class _FloatingBarState extends State<FloatingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationCtrl;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool _visible = true;
  double _lastOffset = 0;

  void _visibility() {
    final pos = widget.scrollCtrl.position;
    final dif = pos.pixels - _lastOffset;

    // If the position has moved enough from the last
    // spot or is out of bounds, update visibility.
    if (dif > 15 || pos.pixels > pos.maxScrollExtent) {
      _lastOffset = widget.scrollCtrl.position.pixels;
      _animationCtrl.forward().then((_) => setState(() => _visible = false));
    } else if (dif < -15 || pos.pixels < pos.minScrollExtent) {
      _lastOffset = widget.scrollCtrl.position.pixels;
      setState(() => _visible = true);
      _animationCtrl.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _slideAnimation = Tween(
      begin: Offset.zero,
      end: const Offset(0, 0.2),
    ).animate(_animationCtrl);
    _fadeAnimation = Tween(begin: 1.0, end: 0.3).animate(_animationCtrl);

    widget.scrollCtrl.addListener(_visibility);
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_visibility);
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}

const _actionButtonSize = 56.0;

/// An [FloatingActionButton] implementation.
class ActionButton extends StatelessWidget {
  ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.onSwipe,
  });

  final IconData icon;
  final String tooltip;
  final void Function() onTap;

  /// If not null, it will signal when the user swipes on the action button.
  /// Passing [true] means 'go right', while [false] means 'go left'. If the
  /// return value is not [null] the new [IconData] will replace the old one
  /// through an animation.
  final IconData? Function(bool)? onSwipe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _actionButtonSize,
      height: _actionButtonSize,
      child: Tooltip(
        message: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(100),
              ),
            ],
          ),
          child: Material(
            color: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              splashColor: Theme.of(context).colorScheme.primaryContainer,
              child: onSwipe == null
                  ? Icon(icon, color: Theme.of(context).colorScheme.onPrimary)
                  : _DraggableIcon(icon: icon, onSwipe: onSwipe!),
            ),
          ),
        ),
      ),
    );
  }
}

// Detects swiping and animates the icon switching.
class _DraggableIcon extends StatefulWidget {
  _DraggableIcon({
    required this.icon,
    required this.onSwipe,
  });

  final IconData icon;
  final IconData? Function(bool) onSwipe;

  @override
  State<_DraggableIcon> createState() => _DraggableIconState();
}

class _DraggableIconState extends State<_DraggableIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late IconData _icon;

  // The icon fades out on exit and fades in on entrance.
  late Animation<double> _opacity;

  // For when the icon exits/enters from the left.
  late Animation<Offset> _left;

  // For when the icon exits/enters from the right.
  late Animation<Offset> _right;

  bool _onRight = false;

  @override
  void initState() {
    super.initState();
    _icon = widget.icon;
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _opacity = Tween(begin: 1.0, end: 0.0).animate(_ctrl);

    _left = Tween(
      begin: Offset.zero,
      end: const Offset(-0.25, 0),
    ).animate(_ctrl);

    _right = Tween(
      begin: Offset.zero,
      end: const Offset(0.25, 0),
    ).animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant _DraggableIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _icon = widget.icon;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragDetector(
      triggerOffset: 10,
      onSwipe: (goRight) {
        // The previous transition must have finished.
        if (_ctrl.isAnimating) return;

        if (_onRight == goRight) setState(() => _onRight = !goRight);

        _ctrl.forward().then((_) {
          setState(() {
            _icon = widget.onSwipe(goRight) ?? _icon;
            _onRight = goRight;
          });
          _ctrl.reverse();
        });
      },
      child: SlideTransition(
        position: _onRight ? _right : _left,
        child: FadeTransition(
          opacity: _opacity,
          child: Icon(
            _icon,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

/// A bottom app bar implementation that uses a blurred, translucent background.
class _BottomBar extends StatelessWidget {
  const _BottomBar(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).viewPadding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: Consts.filter,
        child: Container(
          height: paddingBottom + Consts.tapTargetSize,
          padding: EdgeInsets.only(bottom: paddingBottom),
          color: Theme.of(context).cardColor,
          child: child,
        ),
      ),
    );
  }
}

/// A row with icons for tab switching. If the screen is
/// wide enough, next to the icon will be the name of the tab.
class BottomBarIconTabs extends StatelessWidget {
  const BottomBarIconTabs({
    required this.index,
    required this.items,
    required this.onChanged,
    required this.onSame,
  });

  final int index;
  final Map<String, IconData> items;

  /// Called when a new tab is selected.
  final void Function(int) onChanged;

  /// Called when the currently selected tab is pressed.
  /// Usually this toggles special functionality like search.
  final void Function(int) onSame;

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width > items.length * 130 ? 130.0 : 50.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < items.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => i != index ? onChanged(i) : onSame(i),
            child: SizedBox(
              height: double.infinity,
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items.values.elementAt(i),
                    color: i != index
                        ? Theme.of(context).colorScheme.surfaceVariant
                        : Theme.of(context).colorScheme.primary,
                  ),
                  if (width > 50) ...[
                    const SizedBox(width: 5),
                    Text(
                      items.keys.elementAt(i),
                      style: i != index
                          ? Theme.of(context).textTheme.subtitle1
                          : Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

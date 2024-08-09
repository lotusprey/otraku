import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/navigation_tool.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.builder,
    this.topBar,
    this.floatingActionButton,
    this.navigationConfig,
    this.bottomBar,
    this.floatingActionWhenCompactOnly = false,
    this.sheetMode = false,
  }) : assert(
          navigationConfig == null || bottomBar == null,
          'Cannot have both a navigation bar and a bottom bar',
        );

  final Widget Function(BuildContext context, bool compact) builder;
  final PreferredSizeWidget? topBar;
  final HidingFloatingActionButton? floatingActionButton;
  final NavigationConfig? navigationConfig;
  final Widget? bottomBar;
  final bool floatingActionWhenCompactOnly;
  final bool sheetMode;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < Theming.windowWidthMedium;

    var child = builder(context, compact);
    FloatingActionButtonLocation? floatingActionButtonLocation;
    var bottomNavigationBar = bottomBar;
    if (navigationConfig != null) {
      if (compact) {
        bottomNavigationBar = BottomNavigation(
          selected: navigationConfig!.selected,
          items: navigationConfig!.items,
          onChanged: navigationConfig!.onChanged,
          onSame: navigationConfig!.onSame,
        );
      } else {
        final sideNavigation = SideNavigation(
          selected: navigationConfig!.selected,
          items: navigationConfig!.items,
          onChanged: navigationConfig!.onChanged,
          onSame: navigationConfig!.onSame,
        );

        child = Expanded(child: child);
        child = Row(
          children: Directionality.of(context) == TextDirection.ltr
              ? [sideNavigation, child]
              : [child, sideNavigation],
        );
      }
    }

    Color? backgroundColor;
    bool? resizeToAvoidBottomInset;
    if (sheetMode) {
      backgroundColor = Colors.transparent;
      resizeToAvoidBottomInset = false;
    }

    return Consumer(
      builder: (context, ref, child) {
        if (floatingActionButton != null &&
            (compact || !floatingActionWhenCompactOnly)) {
          final leftHanded = Persistence().leftHanded;

          floatingActionButtonLocation = leftHanded
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat;
        }

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: topBar,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          body: child,
        );
      },
      child: SafeArea(top: false, bottom: false, child: child),
    );
  }
}

/// A configuration that can be shared
/// between bottom navigation bars and navigation rails.
class NavigationConfig {
  const NavigationConfig({
    required this.selected,
    required this.items,
    required this.onChanged,
    required this.onSame,
  });

  final int selected;
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final void Function(int) onSame;
}

/// Hides/Shows [child] on scroll.
class HidingFloatingActionButton extends StatefulWidget {
  const HidingFloatingActionButton({
    required super.key,
    required this.child,
    required this.scrollCtrl,
  });

  final Widget child;
  final ScrollController scrollCtrl;

  @override
  State<HidingFloatingActionButton> createState() =>
      _HidingFloatingActionButtonState();
}

class _HidingFloatingActionButtonState extends State<HidingFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationCtrl;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  var _visible = true;
  var _lastOffset = 0.0;

  void _visibility() {
    final pos = widget.scrollCtrl.positions.last;
    final dif = pos.pixels - _lastOffset;

    // If the position has moved enough from the last
    // spot or is out of bounds, hide/show the actions.
    if (dif > 15 || pos.pixels > pos.maxScrollExtent) {
      _lastOffset = pos.pixels;
      _animationCtrl.reverse().then((_) => setState(() => _visible = false));
    } else if (dif < -15 || pos.pixels < pos.minScrollExtent) {
      _lastOffset = pos.pixels;
      setState(() => _visible = true);
      _animationCtrl.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.addListener(_visibility);

    _animationCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      value: 1,
    );
    _slideAnimation = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_animationCtrl);
    _fadeAnimation = Tween(begin: 0.3, end: 1.0).animate(_animationCtrl);
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_visibility);
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HidingFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scrollCtrl != oldWidget.scrollCtrl) {
      oldWidget.scrollCtrl.removeListener(_visibility);
      widget.scrollCtrl.addListener(_visibility);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

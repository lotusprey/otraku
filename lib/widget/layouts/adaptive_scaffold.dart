import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/navigation_tool.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.builder,
    this.topBar,
    this.floatingActionConfig,
    this.navigationConfig,
    this.bottomBar,
    this.sheetMode = false,
  }) : assert(
          navigationConfig == null || bottomBar == null,
          'Cannot have both a navigation bar and a bottom bar',
        );

  final Widget Function(BuildContext context, bool compact) builder;
  final PreferredSizeWidget? topBar;
  final FloatingActionConfig? floatingActionConfig;
  final NavigationConfig? navigationConfig;
  final Widget? bottomBar;
  final bool sheetMode;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < Theming.windowWidthMedium;

    var child = builder(context, compact);
    Widget? floatingActionButton;
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
        if (floatingActionConfig != null &&
            (compact || !floatingActionConfig!.showOnlyInCompactView)) {
          final leftHanded = Persistence().leftHanded;

          floatingActionButton = _FloatingActionGroup(
            scrollCtrl: floatingActionConfig!.scrollCtrl,
            children: leftHanded
                ? floatingActionConfig!.actions
                : floatingActionConfig!.actions.reversed.toList(),
          );
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

class FloatingActionConfig {
  const FloatingActionConfig({
    required this.scrollCtrl,
    required this.actions,
    this.showOnlyInCompactView = false,
  });

  final ScrollController scrollCtrl;
  final List<Widget> actions;
  final bool showOnlyInCompactView;
}

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

/// A row that hides/shows actions on scroll and animates their replacement.
class _FloatingActionGroup extends StatefulWidget {
  const _FloatingActionGroup({
    required this.scrollCtrl,
    required this.children,
  });

  /// If children might change,
  /// they *must* have keys, for them to be animated correctly.
  final List<Widget> children;
  final ScrollController scrollCtrl;

  @override
  State<_FloatingActionGroup> createState() => _FloatingActionGroupState();
}

class _FloatingActionGroupState extends State<_FloatingActionGroup>
    with SingleTickerProviderStateMixin {
  late List<Widget> _children;
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

    _children = widget.children;
    _animationCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _slideAnimation = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_animationCtrl);
    _fadeAnimation = Tween(begin: 0.3, end: 1.0).animate(_animationCtrl);

    // Actions should appear with an animation.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _animationCtrl.forward(),
    );
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_visibility);
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FloatingActionGroup oldWidget) {
    super.didUpdateWidget(oldWidget);

    // The scroll controller may be different.
    if (widget.scrollCtrl != oldWidget.scrollCtrl) {
      oldWidget.scrollCtrl.removeListener(_visibility);
      widget.scrollCtrl.addListener(_visibility);
    }

    // Hide the actions if they were removed.
    if (widget.children.isEmpty) {
      if (oldWidget.children.isEmpty) return;

      _animationCtrl.value = _animationCtrl.upperBound;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _animationCtrl.reverse().then((_) {
          setState(() {
            _visible = false;
            _children = widget.children;
          });
        }),
      );
      return;
    }

    // Check if the actions are different.
    var changed = widget.children.length != oldWidget.children.length;
    if (!changed) {
      for (int i = 0; i < widget.children.length; i++) {
        if (widget.children[i].key != oldWidget.children[i].key) {
          changed = true;
          break;
        }
      }
    }

    // Don't reanimate if the same actions are already visible.
    if (!changed && _visible) return;

    // Show the actions if they are different or have been hidden.
    _visible = true;
    _children = widget.children;
    _animationCtrl.value = _animationCtrl.lowerBound;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _animationCtrl.forward(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || _children.isEmpty) return const SizedBox();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _children[0],
            for (int i = 1; i < _children.length; i++) ...[
              const SizedBox(width: Theming.offset),
              _children[i],
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/drag_detector.dart';

extension ScaffoldExtension on Scaffold {
  static Widget expanded({
    required Widget child,
    PreferredSizeWidget? topBar,
    FloatingActionConfig? floatingActionConfig,
    Widget? bottomBar,
  }) {
    if (floatingActionConfig == null) {
      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: topBar,
        bottomNavigationBar: bottomBar,
        body: SafeArea(top: false, bottom: false, child: child),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final leftHanded = Persistence().leftHanded;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: topBar,
          bottomNavigationBar: bottomBar,
          floatingActionButton: _FloatingActionGroup(
            scrollCtrl: floatingActionConfig.scrollCtrl,
            children: leftHanded
                ? floatingActionConfig.actions
                : floatingActionConfig.actions.reversed.toList(),
          ),
          floatingActionButtonLocation: leftHanded
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
          body: child,
        );
      },
      child: SafeArea(top: false, bottom: false, child: child),
    );
  }
}

typedef FloatingActionConfig = ({
  ScrollController scrollCtrl,
  List<Widget> actions,
});

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

/// Detects swiping and animates the icon switching.
class DraggableIcon extends StatefulWidget {
  const DraggableIcon({required this.icon, required this.onSwipe});

  final IconData icon;
  final IconData? Function(bool) onSwipe;

  @override
  State<DraggableIcon> createState() => _DraggableIconState();
}

class _DraggableIconState extends State<DraggableIcon>
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
  void didUpdateWidget(covariant DraggableIcon oldWidget) {
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
      triggerOffset: Theming.offset,
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
          child: Icon(_icon),
        ),
      ),
    );
  }
}

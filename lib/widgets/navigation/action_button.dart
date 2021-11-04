import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/utils/overscroll_controller.dart';
import 'package:otraku/widgets/drag_detector.dart';

const _ACTION_BUTTON_SIZE = 56.0;

/// An alternative implementation of [FloatingActionButton].
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
      width: _ACTION_BUTTON_SIZE,
      height: _ACTION_BUTTON_SIZE,
      child: Tooltip(
        message: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
              ),
            ],
          ),
          child: Material(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: onSwipe == null
                  ? Icon(icon, color: Theme.of(context).colorScheme.secondary)
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
    if (widget.icon != oldWidget.icon) _icon = widget.icon;
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
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

/// Hides [child] on scroll-down and reveals it on scroll-up.
class FloatingListener extends StatefulWidget {
  FloatingListener({required this.scrollCtrl, required this.child});

  final MultiScrollController scrollCtrl;
  final Widget child;

  @override
  _FloatingListenerState createState() => _FloatingListenerState();
}

class _FloatingListenerState extends State<FloatingListener>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationCtrl;
  late Animation<double> _animation;

  bool _visible = true;
  double _lastOffset = 0;

  void _visibility() {
    final pos = widget.scrollCtrl.lastPos;
    final dif = pos.pixels - _lastOffset;

    // If the position has moved enough from the last
    // spot or is out of bounds, update visibility.
    if (dif > 10 || pos.pixels > pos.maxScrollExtent) {
      _lastOffset = widget.scrollCtrl.lastPos.pixels;
      _animationCtrl.forward().then((_) => setState(() => _visible = false));
    } else if (dif < -10 || pos.pixels < pos.minScrollExtent) {
      _lastOffset = widget.scrollCtrl.lastPos.pixels;
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
    _animation = Tween(begin: 1.0, end: 0.5).animate(_animationCtrl);

    widget.scrollCtrl.addListener(_visibility);
  }

  @override
  void dispose() {
    if (widget.scrollCtrl.mounted)
      widget.scrollCtrl.removeListener(_visibility);

    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox();

    return ScaleTransition(
      scale: _animation,
      child: FadeTransition(opacity: _animation, child: widget.child),
    );
  }
}

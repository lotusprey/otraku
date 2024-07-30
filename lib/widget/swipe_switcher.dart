import 'package:flutter/material.dart';

/// Animated [children] rotation, based on horizontal swiping or a new [index].
class SwipeSwitcher extends StatefulWidget {
  const SwipeSwitcher({
    required this.index,
    required this.children,
    required this.onChanged,
    this.circular = false,
  });

  final int index;
  final List<Widget> children;
  final void Function(int) onChanged;

  /// Whether you can go after the last child
  /// to arrive at the first one or vice versa.
  final bool circular;

  @override
  State<SwipeSwitcher> createState() => _SwipeSwitcherState();
}

class _SwipeSwitcherState extends State<SwipeSwitcher>
    with SingleTickerProviderStateMixin {
  late final _animationCtrl = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final _goRightAnimation = TweenSequence([
    TweenSequenceItem(
      tween: Tween(begin: Offset.zero, end: const Offset(-0.5, 0)),
      weight: 0.5,
    ),
    TweenSequenceItem(
      tween: Tween(begin: const Offset(0.5, 0), end: Offset.zero),
      weight: 0.5,
    ),
  ]).animate(_animationCtrl);
  late final _fadeAnimation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.5),
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.5),
  ]).animate(_animationCtrl);

  late var _index = widget.index;

  /// Whether the user can *begin* a swipe to go left.
  var _allowGoLeft = true;

  /// Whether the user can *begin* a swipe to go right.
  var _allowGoRight = true;

  /// Horizontal coordinate of where the swipe started.
  var _dragStart = 0.0;

  /// Used to check if a swipe is past the point
  /// at which the child must be swapped.
  var _lastDelta = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAllowedDirections();
  }

  /// When a new [index] is given, the child swapping should be animated.
  @override
  void didUpdateWidget(covariant SwipeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index == widget.index) return;

    _animationCtrl.stop();
    _checkAllowedDirections();

    if (_index < widget.index) {
      _animationCtrl.value = _animationCtrl.lowerBound;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          await _animationCtrl.animateTo(0.5);
          setState(() => _index = widget.index);
          _animationCtrl.animateTo(1.0);
        },
      );
      return;
    }

    _animationCtrl.value = _animationCtrl.upperBound;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await _animationCtrl.animateTo(0.5);
        setState(() => _index = widget.index);
        _animationCtrl.animateTo(0.0);
      },
    );
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }

  /// If not [circular], the user should be blocked
  /// from going beyond the beginning/end.
  void _checkAllowedDirections() {
    if (widget.circular) return;

    _allowGoLeft = _index > 0;
    _allowGoRight = _index < widget.children.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final halfAvailableWidth = constraints.maxWidth / 2.0;

        return GestureDetector(
          onHorizontalDragStart: (details) {
            _dragStart = details.globalPosition.dx;
            _lastDelta = 0.0;
          },
          onHorizontalDragUpdate: (details) {
            final diff = _dragStart - details.globalPosition.dx;
            if (diff <= 0 && !_allowGoLeft || diff >= 0 && !_allowGoRight) {
              return;
            }

            final delta = (diff / halfAvailableWidth).clamp(-1.0, 1.0);
            _animationCtrl.value = delta < 0 ? 1 + delta : delta;

            if (delta >= 0.5 && _lastDelta < 0.5 ||
                delta >= -0.5 && _lastDelta < -0.5) {
              setState(() {
                _index++;

                if (_index >= widget.children.length) _index = 0;
              });

              widget.onChanged(_index);
            } else if (delta <= -0.5 && _lastDelta > -0.5 ||
                delta <= 0.5 && _lastDelta > 0.5) {
              setState(() {
                _index--;

                if (_index <= -1) _index = widget.children.length - 1;
              });

              widget.onChanged(_index);
            }
            _lastDelta = delta;
          },
          onHorizontalDragEnd: (_) => _finishAnimation(),
          onHorizontalDragCancel: _finishAnimation,
          child: SlideTransition(
            position: _goRightAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: widget.children[_index],
            ),
          ),
        );
      },
    );
  }

  // When the user lets go, the child transition should animate to completion.
  void _finishAnimation() {
    _checkAllowedDirections();
    if (_animationCtrl.value >= 0.5) {
      _animationCtrl.animateTo(1.0);
    } else {
      _animationCtrl.animateTo(0.0);
    }
  }
}

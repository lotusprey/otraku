import 'package:flutter/material.dart';

/// [TabSwitcher] animates horizontal swipes between [tabs]. If a new
/// tab is selected externally, [TabSwitcher] animates to it from the
/// current tab, without animating the tabs in between.
class TabSwitcher extends StatefulWidget {
  const TabSwitcher({
    required this.tabs,
    required this.index,
    required this.onChanged,
  }) : assert(index < tabs.length);

  final List<Widget> tabs;
  final int index;
  final void Function(int) onChanged;

  @override
  State<TabSwitcher> createState() => TabSwitcherState();
}

class TabSwitcherState extends State<TabSwitcher>
    with SingleTickerProviderStateMixin {
  /// The distance at which a swipe has fully changed the selected tab.
  static const _fullSwipe = 100.0;

  late final AnimationController _ctrl;

  /// A sequence that slides out the previous tab and slides in the next one.
  late final Animation<Offset> _slideAnimation;

  /// A sequence that fades out the previous tab and fades in the next one.
  late final Animation<double> _fadeAnimation;

  /// [_realIndex] represents the actual selected tab and [_viewIndex] - the
  /// one seen by the user during a swipe. If the swipe has gone at least
  /// halfway, the user will see the neighbouring tab at [_viewIndex].
  /// Otherwise, they will see the original tab at [_realIndex]. While the
  /// user is not swiping, [_realIndex] and [_viewIndex] must be equal.
  late int _realIndex;
  late int _viewIndex;

  /// Keeps track of where the current swipe has begun. Must be [null] when
  /// the user is not swiping or [_ctrl] is performing an animation.
  double? _swipeStart;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-0.5, 0)),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.5, 0), end: Offset.zero),
        weight: 0.5,
      ),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutExpo));

    _fadeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.5),
    ]).animate(_ctrl);

    _realIndex = widget.index;
    _viewIndex = widget.index;
  }

  @override
  void didUpdateWidget(covariant TabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _transitionTo(widget.index);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Animate to a specific tab.
  Future<void> _transitionTo(int index) async {
    _swipeStart = null;

    /// If possible, just reset the view state.
    if (_realIndex == index) {
      _ctrl.value = 0;
      setState(() => _viewIndex = _realIndex);
      return;
    }

    /// Transition to another tab. If there is an ongoing transition, finish
    /// it by replacing the originally expected tab with the one at [index].
    if (_realIndex < index) {
      if (_ctrl.value <= 0.5) {
        await _ctrl.animateTo(0.5);
      } else {
        _ctrl.value = 0.5;
      }
      setState(() => _viewIndex = index);
      await _ctrl.forward();
    } else {
      if (_ctrl.value >= 0.5) {
        await _ctrl.animateBack(0.5);
      } else {
        _ctrl.value = 0.5;
      }
      setState(() => _viewIndex = index);
      await _ctrl.reverse();
    }
    _realIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: widget.tabs[_viewIndex],
        ),
      ),
      onHorizontalDragStart: (start) {
        if (_ctrl.isAnimating) return;
        _swipeStart = start.globalPosition.dx;
      },
      onHorizontalDragUpdate: (update) {
        if (_swipeStart == null) return;

        /// The distance the swipe cursor has travelled. If it's negative,
        /// the user is moving the cursor to the left, which means they want
        /// to go right. Similarly, if the distance is positive, the user wants
        /// to go left.
        final dif = update.globalPosition.dx - _swipeStart!;

        /// The user cannot swipe out of bounds.
        if (dif >= 0 && _realIndex == 0 ||
            dif <= 0 && _realIndex == widget.tabs.length - 1) {
          _swipeStart = null;
          return;
        }

        /// Finish the transition, if the user has swiped far enough.
        if (dif >= _fullSwipe || 0 - dif >= _fullSwipe) {
          _onSwipeEnd();
          return;
        }

        final value = (dif / _fullSwipe).abs();

        if (dif < 0) {
          if (value >= 0.5 && _realIndex >= _viewIndex) {
            setState(() => _viewIndex++);
          } else if (value < 0.5 && _realIndex < _viewIndex) {
            setState(() => _viewIndex--);
          }
        } else {
          if (value >= 0.5 && _realIndex <= _viewIndex) {
            setState(() => _viewIndex--);
          } else if (value < 0.5 && _realIndex > _viewIndex) {
            setState(() => _viewIndex++);
          }
        }

        _ctrl.value = dif < 0 ? value : (1 - value);
      },
      onHorizontalDragEnd: (_) => _onSwipeEnd(),
      onHorizontalDragCancel: _onSwipeEnd,
    );
  }

  /// Finish tab transition if necessary.
  Future<void> _onSwipeEnd() async {
    if (_swipeStart == null) return;
    _swipeStart = null;

    if (_ctrl.value > 0.5 ||
        _ctrl.value > 0.4 && _ctrl.status == AnimationStatus.reverse) {
      if (_ctrl.value <= 0.5) {
        await _ctrl.animateTo(0.5);
        setState(() => _viewIndex++);
      }

      await _ctrl.forward();
      _realIndex = _viewIndex;
      widget.onChanged(_realIndex);
    } else {
      if (_ctrl.value >= 0.5) {
        await _ctrl.animateBack(0.5);
        setState(() => _viewIndex--);
      }

      await _ctrl.reverse();
      _realIndex = _viewIndex;
      widget.onChanged(_realIndex);
    }
  }
}

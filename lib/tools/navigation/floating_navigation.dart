import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FloatingNavigation extends StatefulWidget {
  final ScrollController scrollCtrl;
  final Widget child;

  FloatingNavigation({this.child, this.scrollCtrl});

  @override
  _FloatingNavigationState createState() => _FloatingNavigationState();
}

class _FloatingNavigationState extends State<FloatingNavigation>
    with SingleTickerProviderStateMixin {
  bool _didScrollDown = false;
  bool _hide = false;
  AnimationController _animationController;
  Animation<double> _fadeAnimation;

  void _scrollListener() {
    if (widget.scrollCtrl.position.userScrollDirection ==
        ScrollDirection.idle) {
      return;
    }

    bool newScrollisDown = widget.scrollCtrl.position.userScrollDirection ==
        ScrollDirection.reverse;

    if (newScrollisDown != _didScrollDown) {
      _didScrollDown = newScrollisDown;
      if (_didScrollDown) {
        _animationController
            .forward()
            .then((_) => setState(() => _hide = true));
      } else {
        setState(() => _hide = false);
        _animationController.reverse();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_scrollListener);
    widget.scrollCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: !_hide ? widget.child : Container(),
    );
  }
}

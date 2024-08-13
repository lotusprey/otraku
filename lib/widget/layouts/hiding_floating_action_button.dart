import 'package:flutter/material.dart';

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

import 'package:flutter/material.dart';
import 'package:otraku/utils/overscroll_controller.dart';

// Hides child on scroll-down and reveals it on scroll-up.
class FloatingListener extends StatefulWidget {
  final MultiScrollController scrollCtrl;
  final Widget child;

  FloatingListener({required this.scrollCtrl, required this.child});

  @override
  _FloatingListenerState createState() => _FloatingListenerState();
}

class _FloatingListenerState extends State<FloatingListener>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationCtrl;
  late Animation<double> _animation;

  double _lastOffset = 0;

  void _visibility() {
    final pos = widget.scrollCtrl.lastPos;

    // The position should be in bounds.
    if (pos.pixels < pos.minScrollExtent || pos.pixels > pos.maxScrollExtent)
      return;

    // If the position has moved enough from the last spot, update visibility.
    final dif = pos.pixels - _lastOffset;
    if (dif > 10) {
      _lastOffset = widget.scrollCtrl.lastPos.pixels;
      _animationCtrl.forward();
    } else if (dif < -10) {
      _lastOffset = widget.scrollCtrl.lastPos.pixels;
      _animationCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _animation, child: widget.child);

  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationCtrl);

    widget.scrollCtrl.addListener(_visibility);
  }

  @override
  void dispose() {
    if (widget.scrollCtrl.mounted)
      widget.scrollCtrl.removeListener(_visibility);

    _animationCtrl.dispose();
    super.dispose();
  }
}

// Used tipically as a floating action button.
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final void Function() onTap;

  ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 60,
        height: 60,
        child: Tooltip(
          message: tooltip,
          child: Material(
            elevation: 5,
            color: Theme.of(context).backgroundColor,
            shadowColor: Theme.of(context).backgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              splashColor: Theme.of(context).primaryColor,
              child: Icon(icon, color: Theme.of(context).accentColor),
            ),
          ),
        ),
      );
}

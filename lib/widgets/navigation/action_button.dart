import 'package:flutter/material.dart';
import 'package:otraku/utils/overscroll_controller.dart';

// An implementation of FloatingActionButton.
class ActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final MultiPosScrollCtrl scrollCtrl;
  final void Function() onTap;

  ActionButton({
    required this.icon,
    required this.tooltip,
    required this.scrollCtrl,
    required this.onTap,
  });

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
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
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Tooltip(
          message: widget.tooltip,
          child: Material(
            color: Theme.of(context).backgroundColor,
            elevation: 5,
            shadowColor: Theme.of(context).backgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: widget.onTap,
              splashColor: Theme.of(context).primaryColor,
              child: Icon(widget.icon, color: Theme.of(context).accentColor),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.addListener(_visibility);

    _animationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationCtrl);
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_visibility);
    _animationCtrl.dispose();
    super.dispose();
  }
}

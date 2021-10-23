import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox();

    return ScaleTransition(
      scale: _animation,
      child: FadeTransition(opacity: _animation, child: widget.child),
    );
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
}

const _ACTION_BUTTON_SIZE = 56.0;

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
              child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
      ),
    );
  }
}

// class ActionBar extends StatefulWidget {
//   final Map<String, IconData> items;
//   final void Function(int) onChanged;
//   final void Function() onSame;
//   final int Function() current;

//   const ActionBar({
//     required this.items,
//     required this.onChanged,
//     required this.onSame,
//     required this.current,
//   });

//   @override
//   _ActionBarState createState() => _ActionBarState();
// }

// class _ActionBarState extends State<ActionBar> {
//   late int _index;

//   @override
//   void initState() {
//     super.initState();
//     _index = widget.current();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final radius = BorderRadius.circular(20);

//     return Container(
//       height: _ACTION_BUTTON_SIZE,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.background,
//         borderRadius: radius,
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 5,
//             color: Theme.of(context).colorScheme.primary.withAlpha(100),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           for (int i = 0; i < widget.items.length; i++)
//             if (i != _index)
//               IconButton(
//                 icon: Icon(widget.items.values.elementAt(i)),
//                 tooltip: widget.items.keys.elementAt(i),
//                 color: Theme.of(context).colorScheme.secondary,
//                 onPressed: () {
//                   setState(() => _index = i);
//                   widget.onChanged(i);
//                 },
//               )
//             else
//               Container(
//                 width: _ACTION_BUTTON_SIZE,
//                 height: _ACTION_BUTTON_SIZE,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surface,
//                   borderRadius: radius,
//                 ),
//                 child: IconButton(
//                   icon: Icon(widget.items.values.elementAt(i)),
//                   tooltip: widget.items.keys.elementAt(i),
//                   color: Theme.of(context).colorScheme.secondary,
//                   onPressed: widget.onSame,
//                 ),
//               )
//         ],
//       ),
//     );
//   }
// }

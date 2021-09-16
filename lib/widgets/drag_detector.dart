import 'package:flutter/material.dart';

// Detects horizontal swipes.
class DragDetector extends StatelessWidget {
  // Passing true means 'go right' and false means 'go left'
  final void Function(bool) onSwipe;
  final void Function()? onTap;
  final Widget child;

  DragDetector({required this.child, required this.onSwipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    double? swipeOffset;

    return GestureDetector(
      child: child,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragCancel: () => swipeOffset = null,
      onHorizontalDragStart: (start) => swipeOffset = start.globalPosition.dx,
      onHorizontalDragUpdate: (update) {
        if (swipeOffset == null) return;
        final dif = swipeOffset! - update.globalPosition.dx;

        if (dif > 30) {
          onSwipe(true);
          swipeOffset = null;
        } else if (dif < -30) {
          onSwipe(false);
          swipeOffset = null;
        }
      },
    );
  }
}

import 'package:flutter/material.dart';

// Detects horizontal swipes.
class DragDetector extends StatelessWidget {
  const DragDetector({
    required this.child,
    required this.onSwipe,
    this.triggerOffset = 30,
    this.onTap,
  }) : assert(triggerOffset > 0);

  final Widget child;
  final void Function()? onTap;

  /// Passing `true` means 'go right' and `false` means 'go left'
  final void Function(bool) onSwipe;

  /// How far should the user drag to trigger [onSwipe].
  /// Must be a positive number.
  final double triggerOffset;

  @override
  Widget build(BuildContext context) {
    double? swipeOffset;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (start) => swipeOffset = start.globalPosition.dx,
      onHorizontalDragUpdate: (update) {
        if (swipeOffset == null) return;
        final dif = swipeOffset! - update.globalPosition.dx;

        if (dif > triggerOffset) {
          onSwipe(true);
          swipeOffset = null;
        } else if (dif < -triggerOffset) {
          onSwipe(false);
          swipeOffset = null;
        }
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

/// Rotates between [children] when swiped.
class SwipeSwitcher extends StatelessWidget {
  const SwipeSwitcher({
    required this.index,
    required this.children,
    required this.onChanged,
  });

  final int index;
  final List<Widget> children;
  final void Function(int) onChanged;

  static const _triggerOffset = 20.0;

  @override
  Widget build(BuildContext context) {
    var swipeStart = 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (start) => swipeStart = start.globalPosition.dx,
      onHorizontalDragUpdate: (update) {
        if (swipeStart == 0) return;
        final dif = swipeStart - update.globalPosition.dx;

        if (dif > _triggerOffset) {
          onChanged(index < children.length - 1 ? index + 1 : 0);
          swipeStart = 0;
        } else if (dif < -_triggerOffset) {
          onChanged(index > 0 ? index - 1 : children.length - 1);
          swipeStart = 0;
        }
      },
      child: children[index],
    );
  }
}

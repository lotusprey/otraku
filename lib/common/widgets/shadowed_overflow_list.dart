import 'package:flutter/material.dart';

/// A horizontal list with inner shadow
/// on the left and right that indicates overflow.
class ShadowedOverflowList extends StatelessWidget {
  const ShadowedOverflowList({
    required this.itemCount,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.itemExtent,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double? itemExtent;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 10, right: 5, bottom: 2),
          itemExtent: itemExtent,
          itemCount: itemCount,
          shrinkWrap: shrinkWrap,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(right: 5),
            child: itemBuilder(context, i),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: SizedBox(
            width: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            width: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// A horizontal list with inner shadow
/// on the left and right that indicates overflow.
class ShadowedOverflowList extends StatelessWidget {
  const ShadowedOverflowList({
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
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

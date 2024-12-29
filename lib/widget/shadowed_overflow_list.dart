import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';

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
          padding: const EdgeInsets.only(
            left: Theming.offset,
            right: Theming.offset / 2,
            bottom: 2,
          ),
          itemExtent: itemExtent,
          itemCount: itemCount,
          shrinkWrap: shrinkWrap,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(right: Theming.offset / 2),
            child: itemBuilder(context, i),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: SizedBox(
            width: Theming.offset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ColorScheme.of(context).surface,
                    ColorScheme.of(context).surface.withValues(alpha: 0),
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
            width: Theming.offset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    ColorScheme.of(context).surface,
                    ColorScheme.of(context).surface.withValues(alpha: 0),
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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight
    extends SliverGridDelegate {
  const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight({
    @required this.minWidth,
    @required this.height,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
  })  : assert(minWidth != null && minWidth > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

  final double minWidth;
  final double height;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  bool _debugAssertIsValid() {
    assert(minWidth > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(height > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final crossAxisCount = (constraints.crossAxisExtent + crossAxisSpacing) ~/
        (minWidth + crossAxisSpacing);
    final crossAxisExtent =
        (constraints.crossAxisExtent + crossAxisSpacing) / (crossAxisCount) -
            crossAxisSpacing;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: height + mainAxisSpacing,
      crossAxisStride: crossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: height,
      childCrossAxisExtent: crossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
    SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight oldDelegate,
  ) =>
      oldDelegate.height != height ||
      oldDelegate.minWidth != minWidth ||
      oldDelegate.mainAxisSpacing != mainAxisSpacing ||
      oldDelegate.crossAxisSpacing != crossAxisSpacing;
}

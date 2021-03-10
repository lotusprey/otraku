import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverGridDelegateWithMinWidthAndFixedHeight extends SliverGridDelegate {
  const SliverGridDelegateWithMinWidthAndFixedHeight({
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
    int crossAxisCount =
        constraints.crossAxisExtent ~/ (minWidth + crossAxisSpacing);
    if (crossAxisCount == 0) crossAxisCount++;
    double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    if (usableCrossAxisExtent < 0.0) usableCrossAxisExtent = 0.0;
    final crossAxisExtent = usableCrossAxisExtent / crossAxisCount;

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
    SliverGridDelegateWithMinWidthAndFixedHeight oldDelegate,
  ) =>
      oldDelegate.height != height ||
      oldDelegate.minWidth != minWidth ||
      oldDelegate.mainAxisSpacing != mainAxisSpacing ||
      oldDelegate.crossAxisSpacing != crossAxisSpacing;
}

class SliverGridDelegateWithMaxWidthAndAddedHeight extends SliverGridDelegate {
  const SliverGridDelegateWithMaxWidthAndAddedHeight({
    @required this.maxWidth,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
    this.additionalHeight = 0.0,
    this.rawWHRatio = 1.0,
  })  : assert(maxWidth != null && maxWidth >= 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(additionalHeight != null && additionalHeight >= 0),
        assert(rawWHRatio != null && rawWHRatio > 0);

  final double maxWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double additionalHeight;
  final double rawWHRatio;

  bool _debugAssertIsValid(double crossAxisExtent) {
    assert(crossAxisExtent > 0.0);
    assert(maxWidth > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(additionalHeight >= 0.0);
    assert(rawWHRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid(constraints.crossAxisExtent));

    final crossAxisCount =
        (constraints.crossAxisExtent / (maxWidth + crossAxisSpacing)).ceil();
    double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    if (usableCrossAxisExtent < 0.0) usableCrossAxisExtent = 0.0;
    final childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final childMainAxisExtent =
        childCrossAxisExtent / rawWHRatio + additionalHeight;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      SliverGridDelegateWithMaxWidthAndAddedHeight oldDelegate) {
    return oldDelegate.maxWidth != maxWidth ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.additionalHeight != additionalHeight ||
        oldDelegate.rawWHRatio != rawWHRatio;
  }
}

import 'package:flutter/rendering.dart';

/// Places as many items on the cross axis as possible, without making them
/// narrower than [minWidth]. The item height is fixed.
class SliverGridDelegateWithMinWidthAndFixedHeight extends SliverGridDelegate {
  const SliverGridDelegateWithMinWidthAndFixedHeight({
    required this.minWidth,
    required this.height,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
  })  : assert(minWidth > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0);

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

    int crossAxisCount = (constraints.crossAxisExtent + crossAxisSpacing) ~/
        (minWidth + crossAxisSpacing);

    if (crossAxisCount < 1) crossAxisCount = 1;

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

/// Places as many items on the cross axis as possible, without making them
/// narrower than [minWidth]. The item height is equal to the item width,
/// multiplied by [rawHWRatio] and combined with [extraHeight].
class SliverGridDelegateWithMinWidthAndExtraHeight extends SliverGridDelegate {
  const SliverGridDelegateWithMinWidthAndExtraHeight({
    required this.minWidth,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
    this.extraHeight = 0.0,
    this.rawHWRatio = 1.0,
  })  : assert(minWidth >= 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(extraHeight >= 0),
        assert(rawHWRatio > 0);

  final double minWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double extraHeight;
  final double rawHWRatio;

  bool _debugAssertIsValid() {
    assert(minWidth > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(extraHeight >= 0.0);
    assert(rawHWRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());

    int crossAxisCount = (constraints.crossAxisExtent + crossAxisSpacing) ~/
        (minWidth + crossAxisSpacing);
    if (crossAxisCount < 1) crossAxisCount = 1;

    double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    if (usableCrossAxisExtent < 0.0) usableCrossAxisExtent = 0.0;

    final crossAxisExtent = usableCrossAxisExtent / crossAxisCount;

    final mainAxisExtent = crossAxisExtent * rawHWRatio + extraHeight;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: mainAxisExtent + mainAxisSpacing,
      crossAxisStride: crossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: mainAxisExtent,
      childCrossAxisExtent: crossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
    SliverGridDelegateWithMinWidthAndExtraHeight oldDelegate,
  ) =>
      oldDelegate.minWidth != minWidth ||
      oldDelegate.mainAxisSpacing != mainAxisSpacing ||
      oldDelegate.crossAxisSpacing != crossAxisSpacing ||
      oldDelegate.extraHeight != extraHeight ||
      oldDelegate.rawHWRatio != rawHWRatio;
}

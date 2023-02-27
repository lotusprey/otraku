import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';

/// Simple wrapper around [Scaffold], only supporting a bottom bar.
/// For top bars and floating bars, use [TabScaffold].
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.child,
    this.bottomBar,
  });

  final Widget child;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: bottomBar,
      body: child,
    );
  }
}

/// Must have a [PageScaffold] (or at least a [Scaffold]) ancestor.
/// Simulates floating buttons and top app bars without using [Scaffold].
/// The point is to allow for different top/floating bars on each tab
/// in a page with multiple tabs.
class TabScaffold extends StatelessWidget {
  const TabScaffold({
    required this.child,
    this.topBar,
    this.floatingBar,
  });

  final Widget child;
  final TopBar? topBar;
  final FloatingBar? floatingBar;

  @override
  Widget build(BuildContext context) {
    assert(
      context.findAncestorWidgetOfExactType<PageScaffold>() != null,
      'TabScaffold must have a PageScaffold ancestor',
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (floatingBar != null)
          Positioned(left: 0, right: 0, bottom: 0, child: floatingBar!),
        if (topBar != null)
          Positioned(left: 0, right: 0, top: 0, child: topBar!),
      ],
    );
  }
}

/// Calculates top and bottom offsets, using the device view padding and:
/// - includes the top offset of a potential [TabScaffold] with a top bar.
/// - includes the bottom offset of a potential [PageScaffold]
///   with a bottom bar.
VerticalOffsets scaffoldOffsets(BuildContext context) {
  final inner = context.findAncestorWidgetOfExactType<TabScaffold>();
  final outer = context.findAncestorWidgetOfExactType<PageScaffold>();
  final viewPadding = MediaQuery.of(context).viewPadding;

  var top = viewPadding.top;
  var bottom = viewPadding.bottom;

  if (inner?.topBar != null) top += inner!.topBar!.preferredSize.height;
  if (outer?.bottomBar != null) bottom += Consts.tapTargetSize;

  return VerticalOffsets(top, bottom);
}

class VerticalOffsets {
  const VerticalOffsets(this.top, this.bottom);

  final double top;
  final double bottom;
}

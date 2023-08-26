import 'package:flutter/material.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';

/// Simple wrapper around [Scaffold], only supporting a bottom bar.
/// For top bars and floating bars, use [TabScaffold].
class PageScaffold extends StatefulWidget {
  const PageScaffold({
    required this.child,
    this.bottomBar,
  });

  final Widget child;
  final Widget? bottomBar;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: widget.bottomBar,
      body: widget.child,
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

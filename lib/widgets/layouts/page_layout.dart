import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';

/// A nestable layout that can have bars at the top and bottom like [Scaffold].
/// Nesting instances that both have bottom/floating bars won't work, however.
/// Its main use is to allow a parent [PageLayout] to have a bottom bar
/// for navigation and each tab to be a [PageLayout] with their own
/// top/floating bars.
/// The root [PageLayout] uses [Scaffold], while the descendants don't.
class PageLayout extends StatefulWidget {
  const PageLayout({
    required this.child,
    this.topBar,
    this.floatingBar,
    this.bottomBar,
  });

  final Widget child;
  final TopBar? topBar;
  final FloatingBar? floatingBar;
  final Widget? bottomBar;

  static double topPadding(BuildContext context) =>
      MediaQuery.of(context).viewPadding.top + Consts.tapTargetSize;

  static double bottomPadding(BuildContext context) =>
      MediaQuery.of(context).viewPadding.bottom + Consts.tapTargetSize;

  @override
  State<PageLayout> createState() => PageLayoutState();
}

class PageLayoutState extends State<PageLayout> {
  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (widget.bottomBar != null)
          Positioned(bottom: 0, left: 0, right: 0, child: widget.bottomBar!),
        if (widget.topBar != null)
          Positioned(top: 0, left: 0, right: 0, child: widget.topBar!),
        if (widget.floatingBar != null)
          Align(alignment: Alignment.bottomCenter, child: widget.floatingBar),
      ],
    );
    final parent = context.findAncestorStateOfType<PageLayoutState>();
    return parent != null ? child : Scaffold(body: child);
  }
}

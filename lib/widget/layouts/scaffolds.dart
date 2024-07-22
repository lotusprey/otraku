import 'package:flutter/material.dart';
import 'package:otraku/widget/layouts/top_bar.dart';

/// Simulates floating buttons and top app bars without using [Scaffold].
/// The point is to allow for different top/floating bars on each tab
/// in a page with multiple tabs.
class TabScaffold extends StatelessWidget {
  const TabScaffold({required this.child, required this.topBar});

  final Widget child;
  final TopBar topBar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(left: 0, right: 0, top: 0, child: topBar),
      ],
    );
  }
}

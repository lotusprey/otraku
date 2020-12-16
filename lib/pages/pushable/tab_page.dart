import 'package:flutter/material.dart';

class TabPage extends StatelessWidget {
  final Widget child;
  final Widget drawer;

  TabPage(this.child, {this.drawer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Theme.of(context).primaryColor.withAlpha(150),
      drawer: drawer,
      body: SafeArea(
        child: child,
      ),
    );
  }
}

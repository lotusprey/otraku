import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class NavScaffold extends StatelessWidget {
  final Widget child;
  final NavBar navBar;
  final Widget? floating;

  const NavScaffold({
    required this.child,
    required this.navBar,
    this.floating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: navBar,
      floatingActionButton: floating,
      floatingActionButtonLocation:
          (Config.storage.read(Config.LEFT_HANDED) ?? false)
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
      body: SafeArea(bottom: false, child: child),
    );
  }
}

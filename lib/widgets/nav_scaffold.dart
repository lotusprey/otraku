import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class NavScaffold extends StatelessWidget {
  final Widget child;
  final NavBar navBar;
  final Widget? floating;
  final ShadowAppBar? appBar;

  const NavScaffold({
    required this.child,
    required this.navBar,
    this.floating,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: child,
    );

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: navBar,
      floatingActionButton: floating,
      floatingActionButtonLocation:
          (Config.storage.read(Config.LEFT_HANDED) ?? false)
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
      extendBody: true,
      body: appBar == null ? SafeArea(bottom: false, child: body) : body,
    );
  }
}

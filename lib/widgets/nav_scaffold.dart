import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class NavScaffold extends StatelessWidget {
  final Widget child;
  final Map<String, IconData> items;
  final void Function(int) setPage;
  final int index;
  final Widget? floating;
  final ShadowAppBar? appBar;

  // When a tab swipe is detected, NavScaffold will try to switch the subtab of
  // the page, instead of the tab itself. For 'go right' true is passed to the
  // callback and for 'go left' - false. The returned value determines whether
  // the subtab has been switched. If not (the end of the subtab carousel has
  // been reached), NavScaffold will switch the tab.
  final bool Function(bool)? trySubtab;

  const NavScaffold({
    required this.child,
    required this.items,
    required this.setPage,
    this.trySubtab,
    this.index = 0,
    this.floating,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final body = DragDetector(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
      onSwipe: (goRight) {
        // Try to switch the subtab, instead of the tab.
        if (trySubtab?.call(goRight) ?? false) return;

        if (goRight) {
          if (index < items.length - 1) setPage(index + 1);
        } else {
          if (index > 0) setPage(index - 1);
        }
      },
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floating,
      floatingActionButtonLocation:
          (Config.storage.read(Config.LEFT_HANDED) ?? false)
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
      extendBody: true,
      bottomNavigationBar: NavBar(
        items: items,
        initial: index,
        onChanged: setPage,
      ),
      body: SafeArea(bottom: false, child: body),
    );
  }
}

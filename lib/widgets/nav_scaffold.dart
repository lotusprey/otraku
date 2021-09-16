import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class NavScaffold extends StatelessWidget {
  final Widget child;
  final Map<String, IconData> items;
  final void Function(int) setPage;
  final int index;
  final Widget? floating;
  final ShadowAppBar? appBar;

  const NavScaffold({
    required this.child,
    required this.items,
    required this.setPage,
    this.index = 0,
    this.floating,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    double? swipeOffset;

    final body = GestureDetector(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragCancel: () => swipeOffset = null,
      onHorizontalDragStart: (start) => swipeOffset = start.globalPosition.dx,
      onHorizontalDragUpdate: (update) {
        if (swipeOffset == null) return;
        final dif = swipeOffset! - update.globalPosition.dx;

        if (dif > 30) {
          if (index < items.length - 1) setPage(index + 1);
          swipeOffset = null;
        } else if (dif < -30) {
          if (index > 0) setPage(index - 1);
          swipeOffset = null;
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
      body: appBar == null ? SafeArea(bottom: false, child: body) : body,
    );
  }
}

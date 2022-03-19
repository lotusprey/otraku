import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/drag_detector.dart';

class NavLayout extends StatelessWidget {
  NavLayout({
    required this.child,
    this.navRow,
    this.floating,
    this.trySubtab,
    this.appBar,
  });

  final Widget child;
  final NavRow? navRow;
  final Widget? floating;
  final PreferredSizeWidget? appBar;

  /// When a tab swipe is detected, [NavLayout] will try to switch the subtab
  /// of the page, instead of the tab itself. For 'go right' [true] is passed
  /// to the callback and for 'go left' - [false]. The returned value
  /// determines whether the subtab has been switched. If not (the
  /// end of the subtab carousel has been reached), it will
  /// attempt to switch the tab with [NavRow.move].
  final bool Function(bool)? trySubtab;

  // Needed offset from the bottom of the page, to
  // avoid the bottom app bar (if present).
  static double offset(BuildContext ctx) =>
      MediaQuery.of(ctx).viewPadding.bottom + 60;

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    /// If there is a [navRow], swiping between tabs is possible.
    if (navRow != null)
      body = DragDetector(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
        onSwipe: (goRight) {
          // Try to switch the subtab, instead of the tab.
          if (trySubtab?.call(goRight) ?? false) return;

          // Otherwise, try switching the tab.
          navRow?.switchTab(goRight);
        },
      );

    return Scaffold(
      extendBody: true,
      appBar: appBar,
      floatingActionButton: floating,
      floatingActionButtonLocation: Settings().leftHanded
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: navRow != null
          ? ClipRect(
              child: BackdropFilter(
                filter: Consts.filter,
                child: Container(
                  height: MediaQuery.of(context).viewPadding.bottom + 50,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewPadding.bottom,
                  ),
                  color: Theme.of(context).cardColor,
                  child: navRow,
                ),
              ),
            )
          : null,
    );
  }
}

/// The [NavLayout] should be able to switch the tab
/// by swiping. In that case, it will call [switchTab].
abstract class NavRow extends StatelessWidget {
  NavRow(this.onChanged, this.index);

  final void Function(int) onChanged;
  final int index;

  /// Tab count.
  int get tabLength;

  void switchTab(bool goRight) {
    if (goRight) {
      if (index < tabLength - 1) onChanged(index + 1);
    } else {
      if (index > 0) onChanged(index - 1);
    }
  }
}

/// A [NavRow] with tabs, represented as icons. If the screen is
/// wide enough, next to the icon will be the name of the tab.
class NavIconRow extends NavRow {
  NavIconRow({
    required this.items,
    required this.onSame,
    required int index,
    required void Function(int) onChanged,
  }) : super(onChanged, index);

  final Map<String, IconData> items;

  /// Called when the currently selected tab is pressed.
  /// Usually this toggles special functionality like search.
  final void Function(int) onSame;

  @override
  int get tabLength => items.length;

  @override
  Widget build(BuildContext context) {
    // Navigation bar item width.
    late final width;
    if (MediaQuery.of(context).size.width > items.length * 130)
      width = 130.0;
    else
      width = 50.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < items.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => i != index ? onChanged(i) : onSame(i),
            child: SizedBox(
              height: double.infinity,
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items.values.elementAt(i),
                    color: i != index
                        ? null
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  if (width > 50) ...[
                    const SizedBox(width: 5),
                    Text(
                      items.keys.elementAt(i),
                      style: i != index
                          ? Theme.of(context).textTheme.subtitle1
                          : Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

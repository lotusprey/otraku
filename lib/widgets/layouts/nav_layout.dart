import 'package:flutter/material.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

/// A [Scaffold] with a custom [Scaffold.bottomNavigationBar]
/// and a tab transition animation.
class NavLayout extends StatelessWidget {
  const NavLayout({
    required this.child,
    required this.items,
    required this.onChanged,
    this.index = 0,
    this.trySubtab,
    this.floating,
    this.appBar,
  });

  final Widget child;
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final int index;
  final Widget? floating;
  final ShadowAppBar? appBar;

  /// When a tab swipe is detected, [NavLayout] will try to switch the subtab
  /// of the page, instead of the tab itself. For 'go right' [true] is passed to
  /// the callback and for 'go left' - [false]. The returned value determines
  /// whether the subtab has been switched. If not (the end of the subtab
  /// carousel has been reached), [NavLayout] will switch the tab.
  final bool Function(bool)? trySubtab;

  // At the bottom of a page there should be this offset
  // in order to avoid obstruction by the bottom bar.
  static double offset(BuildContext ctx) =>
      MediaQuery.of(ctx).viewPadding.bottom + 60;

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
          if (index < items.length - 1) onChanged(index + 1);
        } else {
          if (index > 0) onChanged(index - 1);
        }
      },
    );

    final full = MediaQuery.of(context).size.width > items.length * 130;

    return Scaffold(
      extendBody: true,
      appBar: appBar,
      floatingActionButton: floating,
      floatingActionButtonLocation: LocalSettings().leftHanded
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: Config.filter,
          child: Container(
            height: MediaQuery.of(context).viewPadding.bottom + 50,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom,
            ),
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < items.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (i != index) onChanged(i);
                    },
                    child: SizedBox(
                      height: double.infinity,
                      width: full ? 130 : 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items.values.elementAt(i),
                            color: i != index
                                ? null
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          if (full) ...[
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
            ),
          ),
        ),
      ),
    );
  }
}

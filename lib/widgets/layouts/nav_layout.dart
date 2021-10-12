import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class NavLayout extends StatefulWidget {
  final Widget child;
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final int index;
  final Widget? floating;
  final ShadowAppBar? appBar;

  /// When a tab swipe is detected, [NavLayout] will try to switch the subtab
  /// of the page, instead of the tab itself. For 'go right' true is passed to
  /// the callback and for 'go left' - false. The returned value determines
  /// whether the subtab has been switched. If not (the end of the subtab
  /// carousel has been reached), [NavLayout] will switch the tab.
  final bool Function(bool)? trySubtab;

  const NavLayout({
    required this.child,
    required this.items,
    required this.onChanged,
    this.trySubtab,
    this.index = 0,
    this.floating,
    this.appBar,
  });

  @override
  State<NavLayout> createState() => _NavLayoutState();

  // At the bottom of a page there should be this offset
  // in order to avoid obstruction by the navbar.
  static double offset(BuildContext ctx) =>
      MediaQuery.of(ctx).viewPadding.bottom + 60;
}

class _NavLayoutState extends State<NavLayout> {
  late Tween<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _slide = Tween(begin: Offset.zero, end: Offset.zero);
  }

  @override
  void didUpdateWidget(covariant NavLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index > oldWidget.index)
      _slide = Tween(begin: const Offset(0.5, 0), end: Offset.zero);
    else if (widget.index < oldWidget.index)
      _slide = Tween(begin: const Offset(-0.5, 0), end: Offset.zero);
    else
      _slide = Tween(begin: Offset.zero, end: Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final body = DragDetector(
      child: AnimatedSwitcher(
        child: widget.child,
        switchInCurve: Curves.easeOutExpo,
        switchOutCurve: Curves.easeInExpo,
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: _slide.animate(animation),
            child: child,
          ),
        ),
      ),
      onSwipe: (goRight) {
        // Try to switch the subtab, instead of the tab.
        if (widget.trySubtab?.call(goRight) ?? false) return;

        if (goRight) {
          if (widget.index < widget.items.length - 1)
            widget.onChanged(widget.index + 1);
        } else {
          if (widget.index > 0) widget.onChanged(widget.index - 1);
        }
      },
    );

    final full = MediaQuery.of(context).size.width > widget.items.length * 130;

    return Scaffold(
      extendBody: true,
      appBar: widget.appBar,
      floatingActionButton: widget.floating,
      floatingActionButtonLocation:
          (Config.storage.read(Config.LEFT_HANDED) ?? false)
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
                for (int i = 0; i < widget.items.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (i != widget.index) widget.onChanged(i);
                    },
                    child: SizedBox(
                      height: double.infinity,
                      width: full ? 130 : 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.items.values.elementAt(i),
                            color: i != widget.index
                                ? null
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          if (full) ...[
                            const SizedBox(width: 5),
                            Text(
                              widget.items.keys.elementAt(i),
                              style: i != widget.index
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

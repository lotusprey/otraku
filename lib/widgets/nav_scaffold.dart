import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class NavScaffold extends StatefulWidget {
  final Widget child;
  final Map<String, IconData> items;
  final void Function(int) setPage;
  final int index;
  final Widget? floating;
  final ShadowAppBar? appBar;

  /// When a tab swipe is detected, [NavScaffold] will try to switch the subtab
  /// of the page, instead of the tab itself. For 'go right' true is passed to
  /// the callback and for 'go left' - false. The returned value determines
  /// whether the subtab has been switched. If not (the end of the subtab
  /// carousel has been reached), [NavScaffold] will switch the tab.
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
  State<NavScaffold> createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<NavScaffold> {
  late Tween<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _slide = Tween(begin: Offset.zero, end: Offset.zero);
  }

  @override
  void didUpdateWidget(covariant NavScaffold oldWidget) {
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
            widget.setPage(widget.index + 1);
        } else {
          if (widget.index > 0) widget.setPage(widget.index - 1);
        }
      },
    );

    return Scaffold(
      extendBody: true,
      appBar: widget.appBar,
      floatingActionButton: widget.floating,
      floatingActionButtonLocation:
          (Config.storage.read(Config.LEFT_HANDED) ?? false)
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavBar(
        items: widget.items,
        initial: widget.index,
        onChanged: widget.setPage,
      ),
      body: SafeArea(bottom: false, child: body),
    );
  }
}

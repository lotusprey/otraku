import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';

/// On large screen with multiple panes, you may want to have a tab bar on only
/// one of the panes, in which case you can't use the [Scaffold]'s
/// [AppBar] slot. Then [StackedTabBar] can be used instead.
class StackedTabBar extends StatelessWidget {
  const StackedTabBar({
    required this.child,
    required this.tabs,
    required this.tabCtrl,
    required this.scrollToTop,
  });

  final Widget child;
  final List<Tab> tabs;
  final TabController tabCtrl;
  final void Function() scrollToTop;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + Theming.normalTapTarget;

    return Stack(
      children: [
        MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(top: topPadding),
          ),
          child: child,
        ),
        ClipRect(
          child: BackdropFilter(
            filter: Theming.blurFilter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).navigationBarTheme.backgroundColor,
              ),
              child: SizedBox(
                height: topPadding,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      splashBorderRadius: Theming.borderRadiusSmall,
                      tabs: tabs,
                      controller: tabCtrl,
                      onTap: (index) {
                        if (index == tabCtrl.index) {
                          scrollToTop();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

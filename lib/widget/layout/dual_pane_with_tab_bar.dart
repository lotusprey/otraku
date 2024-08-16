import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';

/// Two panes side by side, the left with capped width.
/// There's a tab bar over the right one.
class DualPaneWithTabBar extends StatelessWidget {
  const DualPaneWithTabBar({
    required this.tabs,
    required this.tabCtrl,
    required this.scrollToTop,
    required this.leftPane,
    required this.rightPane,
  });

  final List<Tab> tabs;
  final TabController tabCtrl;
  final void Function() scrollToTop;
  final Widget leftPane;
  final Widget rightPane;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + Theming.normalTapTarget;

    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Theming.windowWidthMedium,
            ),
            child: leftPane,
          ),
        ),
        Flexible(
          child: Stack(
            children: [
              MediaQuery(
                data: mediaQuery.copyWith(
                  padding: mediaQuery.padding.copyWith(top: topPadding),
                ),
                child: rightPane,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: Theming.blurFilter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .navigationBarTheme
                            .backgroundColor,
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
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

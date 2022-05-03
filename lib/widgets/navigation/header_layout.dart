import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class HeaderLayout extends StatelessWidget {
  const HeaderLayout({
    required this.topItems,
    required this.builder,
    this.canPop = false,
  });

  final List<Widget> topItems;
  final Widget Function(BuildContext, double) builder;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).viewPadding.top;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Consts.LAYOUT_BIG),
        child: Stack(
          fit: StackFit.expand,
          children: [
            builder(context, paddingTop + Consts.TAP_TARGET_SIZE + 10),
            Positioned(
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: Consts.filter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: paddingTop),
                      child: SizedBox(
                        height: Consts.TAP_TARGET_SIZE,
                        child: Row(
                          children: [
                            if (canPop)
                              AppBarIcon(
                                tooltip: 'Close',
                                icon: Ionicons.chevron_back_outline,
                                onTap: () => Navigator.pop(context),
                              ),
                            ...topItems,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

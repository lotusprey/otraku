import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

class TranslucentLayout extends StatelessWidget {
  const TranslucentLayout({required this.builder, required this.topItems});

  final Widget Function(double) builder;
  final List<Widget> topItems;

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).viewPadding.top;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Consts.LAYOUT_BIG),
        child: Stack(
          fit: StackFit.expand,
          children: [
            builder(paddingTop + Consts.TAP_TARGET_SIZE + 10),
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
                        child: Row(children: topItems),
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

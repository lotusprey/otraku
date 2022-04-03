import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

class TranslucentLayout extends StatelessWidget {
  const TranslucentLayout({required this.builder, required this.headerItems});

  final Widget Function(double) builder;
  final List<Widget> headerItems;

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).viewPadding.top;
    print(paddingTop);

    return Stack(
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
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: Padding(
                  padding: EdgeInsets.only(top: paddingTop),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: Consts.TAP_TARGET_SIZE,
                        maxHeight: Consts.TAP_TARGET_SIZE,
                        maxWidth: Consts.LAYOUT_BIG,
                      ),
                      child: Row(children: headerItems),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

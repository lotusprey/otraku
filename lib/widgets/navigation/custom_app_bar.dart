import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/widgets/action_icon.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double CUSTOM_APP_BAR_HEIGHT = 50;

  final IconData leading;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> trailing;

  CustomAppBar({
    this.leading = FluentIcons.arrow_left_24_filled,
    this.title = '',
    this.titleWidget,
    this.trailing = const [],
  }) {
    const box = SizedBox(width: 15);
    for (int i = 1; i < trailing.length; i += 2) trailing.insert(i, box);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: CUSTOM_APP_BAR_HEIGHT,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).backgroundColor,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            ActionIcon(
              tooltip: 'Close',
              icon: leading,
              dimmed: false,
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: titleWidget != null
                  ? titleWidget!
                  : Text(
                      title!,
                      style: Theme.of(context).textTheme.headline2,
                    ),
            ),
            ...trailing,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(CUSTOM_APP_BAR_HEIGHT);
}

class AppBarIcon extends StatelessWidget {
  final Widget child;

  const AppBarIcon(this.child);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      child: child,
    );
  }
}

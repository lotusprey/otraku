import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double CUSTOM_APP_BAR_HEIGHT = 50;

  final IconData leading;
  final String title;
  final Widget titleWidget;
  final List<Widget> trailing;
  final bool wrapTrailing;

  CustomAppBar({
    this.leading = FluentSystemIcons.ic_fluent_arrow_left_filled,
    this.title = '',
    this.titleWidget,
    this.trailing,
    this.wrapTrailing = true,
  });

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
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBarIcon(IconButton(
              tooltip: 'Close',
              icon: Icon(leading),
              onPressed: () => Navigator.of(context).pop(),
            )),
            Expanded(
              child: titleWidget != null
                  ? titleWidget
                  : Text(
                      title,
                      style: Theme.of(context).textTheme.headline3,
                    ),
            ),
            trailing != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: wrapTrailing
                        ? trailing.map((t) => AppBarIcon(t)).toList()
                        : trailing)
                : const SizedBox(),
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

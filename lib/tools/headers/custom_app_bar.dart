import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double CUSTOM_APP_BAR_HEIGHT = 50;

  final IconData leading;
  final String title;
  final List<Widget> trailing;
  final bool wrapTrailing;

  CustomAppBar({
    this.leading = FeatherIcons.arrowLeft,
    this.title = '',
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: AppBarIcon(IconButton(
                icon: Icon(leading),
                color: Theme.of(context).accentColor,
                onPressed: () => Navigator.of(context).pop(),
              )),
            ),
            if (trailing != null)
              Positioned(
                right: 0,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: wrapTrailing
                        ? trailing.map((t) => AppBarIcon(t)).toList()
                        : trailing),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.headline3,
            ),
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

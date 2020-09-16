import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double CUSTOM_APP_BAR_HEIGHT = 50;

  final IconData leading;
  final String title;
  final List<Widget> trailing;

  CustomAppBar({
    this.leading = LineAwesomeIcons.arrow_left,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

    return SafeArea(
      child: Container(
        height: CUSTOM_APP_BAR_HEIGHT,
        decoration: BoxDecoration(
          color: palette.background,
          boxShadow: [
            BoxShadow(
              color: palette.background,
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
              child: _AppBarIcon(IconButton(
                icon: Icon(leading),
                color: palette.accent,
                iconSize: Palette.ICON_MEDIUM,
                onPressed: () => Navigator.of(context).pop(),
              )),
            ),
            if (trailing != null)
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: trailing.map((t) => _AppBarIcon(t)).toList(),
                ),
              ),
            Text(
              title,
              style: palette.contrastedTitle,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(CUSTOM_APP_BAR_HEIGHT);
}

class _AppBarIcon extends StatelessWidget {
  final Widget child;

  _AppBarIcon(this.child);

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

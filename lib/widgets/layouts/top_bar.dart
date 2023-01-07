import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';

/// A top app bar implementation that uses a blurred, translucent background.
/// It has (in order):
/// - A button to pop the page (if [canPop] is `true`).
/// - The formatted [title] (if not `null`).
/// - The [trailing] widgets (if the list is not empty).
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({this.trailing = const [], this.canPop = true, this.title});

  final bool canPop;
  final String? title;
  final List<Widget> trailing;

  @override
  Size get preferredSize => const Size.fromHeight(Consts.tapTargetSize);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: Consts.filter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarColor,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      if (canPop)
                        TopBarIcon(
                          tooltip: 'Close',
                          icon: Ionicons.chevron_back_outline,
                          onTap: () => Navigator.maybePop(context),
                        )
                      else
                        const SizedBox(width: 10),
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ...trailing,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An [IconButton] customised for a top app bar.
class TopBarIcon extends StatelessWidget {
  const TopBarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.accented = false,
  });

  final IconData icon;
  final String tooltip;
  final void Function() onTap;
  final bool accented;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 45,
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onTap,
        color: accented
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onBackground,
        padding: Consts.padding,
      ),
    );
  }
}

/// A [TopBarIcon] casting a shadow. Used when the background is a banner.
class TopBarShadowIcon extends StatelessWidget {
  const TopBarShadowIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.background,
              blurRadius: 10,
              spreadRadius: -10,
            ),
          ],
        ),
        child: TopBarIcon(icon: icon, tooltip: tooltip, onTap: onTap),
      );
}

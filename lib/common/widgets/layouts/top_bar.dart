import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';

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
        filter: Consts.blurFilter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).navigationBarTheme.backgroundColor,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            child: Center(
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
                          style: Theme.of(context).textTheme.titleLarge,
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

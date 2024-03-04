import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/extensions.dart';

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

  static const height = 55.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipRect(
      child: BackdropFilter(
        filter: Consts.blurFilter,
        child: Container(
          height: topPadding + preferredSize.height,
          decoration: BoxDecoration(
            color: Theme.of(context).navigationBarTheme.backgroundColor,
          ),
          padding: EdgeInsets.only(top: topPadding),
          alignment: Alignment.center,
          child: Row(
            children: [
              if (canPop)
                TopBarIcon(
                  tooltip: 'Close',
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: context.back,
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

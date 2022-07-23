import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';

/// A bottom app bar implementation that uses a blurred, translucent background.
class BottomBar extends StatelessWidget {
  const BottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).viewPadding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: Consts.filter,
        child: Container(
          height: paddingBottom + Consts.tapTargetSize,
          padding: EdgeInsets.only(bottom: paddingBottom),
          color: Theme.of(context).cardColor,
          child: child,
        ),
      ),
    );
  }
}

/// A [BottomBar] implementation with icons for tab switching. If the screen
/// is wide enough, next to each icon will be the name of the tab.
class BottomBarIconTabs extends StatelessWidget {
  const BottomBarIconTabs({
    required this.current,
    required this.items,
    required this.onChanged,
    required this.onSame,
  });

  final int current;
  final Map<String, IconData> items;

  /// Called when a new tab is selected.
  final void Function(int) onChanged;

  /// Called when the currently selected tab is pressed.
  /// Usually this toggles special functionality like search.
  final void Function(int) onSame;

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width > items.length * 130 ? 130.0 : 50.0;

    return BottomBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => i != current ? onChanged(i) : onSame(i),
              child: SizedBox(
                height: double.infinity,
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items.values.elementAt(i),
                      color: i != current
                          ? Theme.of(context).colorScheme.surfaceVariant
                          : Theme.of(context).colorScheme.primary,
                    ),
                    if (width > 50) ...[
                      const SizedBox(width: 5),
                      Text(
                        items.keys.elementAt(i),
                        style: i != current
                            ? Theme.of(context).textTheme.subtitle1
                            : Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A [BottomBar] implementation with 2 buttons. If [primary] is `null`,
/// there will be a [Loader] in its place. If [secondary] is `null`,
/// there won't be anything in its place.
class BottomBarDualButtonRow extends StatelessWidget {
  const BottomBarDualButtonRow({
    required this.primary,
    required this.secondary,
  });

  final BottomBarButton? primary;
  final BottomBarButton? secondary;

  @override
  Widget build(BuildContext context) {
    final primary = this.primary != null
        ? this.primary!
        : const Expanded(child: Center(child: Loader()));
    final secondary = this.secondary != null ? this.secondary! : const Spacer();

    return BottomBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            if (Settings().leftHanded) ...[
              primary,
              secondary,
            ] else ...[
              secondary,
              primary,
            ],
          ],
        ),
      ),
    );
  }
}

/// A [TextButton] implementation.
class BottomBarButton extends StatelessWidget {
  const BottomBarButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.warning = false,
  });

  final String text;
  final IconData icon;
  final void Function() onTap;

  // If the icon/text should be in the error colour.
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        label: Text(text),
        icon: Icon(icon),
        onPressed: onTap,
        style: TextButton.styleFrom(
          primary: warning ? Theme.of(context).colorScheme.error : null,
        ),
      ),
    );
  }
}

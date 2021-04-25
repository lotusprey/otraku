import 'package:flutter/material.dart';
import 'package:otraku/enums/themes.dart';

class ActionIcon extends StatelessWidget {
  final bool dimmed;
  final IconData icon;
  final String tooltip;
  final void Function() onPressed;

  ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.dimmed = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      color: dimmed ? null : Theme.of(context).dividerColor,
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(
        maxHeight: Style.ICON_BIG,
        maxWidth: Style.ICON_BIG,
      ),
    );
  }
}

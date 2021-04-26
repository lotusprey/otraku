import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  final bool dimmed;
  final bool active;
  final IconData icon;
  final String tooltip;
  final void Function() onTap;
  final void Function()? onLongPress;

  ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.dimmed = true,
    this.active = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Icon(
      icon,
      color: active
          ? Theme.of(context).accentColor
          : dimmed
              ? null
              : Theme.of(context).dividerColor,
    );

    return InkResponse(
      onTap: onTap,
      onLongPress: onLongPress,
      child: active
          ? widget
          : Tooltip(
              message: tooltip,
              child: widget,
            ),
    );
  }
}

import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  final bool dimmed;
  final bool active;
  final IconData icon;
  final String tooltip;
  final void Function() onTap;

  ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.dimmed = true,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Icon(
          icon,
          color: active
              ? Theme.of(context).accentColor
              : dimmed
                  ? null
                  : Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

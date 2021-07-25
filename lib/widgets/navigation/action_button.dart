import 'package:flutter/material.dart';

// An implementation of FloatingActionButton.
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final void Function() onTap;

  ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Theme.of(context).backgroundColor,
          elevation: 5,
          shadowColor: Theme.of(context).backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            splashColor: Theme.of(context).primaryColor,
            child: Icon(icon, color: Theme.of(context).accentColor),
          ),
        ),
      ),
    );
  }
}

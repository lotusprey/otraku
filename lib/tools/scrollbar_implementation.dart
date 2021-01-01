import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';

class ScrollbarImplementation extends StatelessWidget {
  final Widget child;

  ScrollbarImplementation(this.child);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(highlightColor: Theme.of(context).accentColor),
      child: Scrollbar(
        radius: Config.RADIUS,
        child: child,
      ),
    );
  }
}

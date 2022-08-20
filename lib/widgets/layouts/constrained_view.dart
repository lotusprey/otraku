import 'package:flutter/widgets.dart';
import 'package:otraku/constants/consts.dart';

/// Horizontally constrains [child] into the center.
class ConstrainedView extends StatelessWidget {
  const ConstrainedView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class InputFieldStructure extends StatelessWidget {
  static const _space = SizedBox(height: 5);

  final String title;
  final Widget body;
  final bool enforceHeight;
  final bool enforcePadding;

  InputFieldStructure({
    @required this.title,
    @required this.body,
    this.enforceHeight = true,
    this.enforcePadding = true,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: enforceHeight ? 85 : null,
        padding: enforcePadding ? const EdgeInsets.only(bottom: 10) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            _space,
            body,
          ],
        ),
      );
}

import 'package:flutter/material.dart';

class InputFieldStructure extends StatelessWidget {
  static const _space = SizedBox(height: 5);

  final String title;
  final Widget body;
  final bool enforceHeight;

  InputFieldStructure({
    @required this.title,
    @required this.body,
    this.enforceHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: enforceHeight ? 75 : null,
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
}

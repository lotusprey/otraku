import 'package:flutter/material.dart';

class InputFieldStructure extends StatelessWidget {
  final _space = const SizedBox(height: 5);

  final String title;
  final Widget child;

  InputFieldStructure({
    @required this.title,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          _space,
          child,
        ],
      );
}

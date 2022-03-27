import 'package:flutter/material.dart';

// A wrapper that puts a label on top of a widget.
class LabeledField extends StatelessWidget {
  LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.subtitle1),
          const SizedBox(height: 5),
          child,
        ],
      );
}

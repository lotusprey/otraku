import 'package:flutter/material.dart';

// A wrapper that puts a label on top of a widget.
class LabeledField extends StatelessWidget {
  const LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.subtitle1),
        child,
      ],
    );
  }
}

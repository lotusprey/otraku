import 'package:flutter/material.dart';

/// Lists text details in a fancy way, marking
/// the ones that come with a [true] value.
class TextRail extends StatelessWidget {
  const TextRail(this.items, {this.style, this.maxLines});

  final Map<String, bool> items;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    const spacing = TextSpan(text: ' • ');

    final style = this.style ?? Theme.of(context).textTheme.labelSmall;
    final highlightStyle = style?.copyWith(
      color: Theme.of(context).colorScheme.primary,
    );

    return Text.rich(
      overflow: TextOverflow.fade,
      maxLines: maxLines,
      TextSpan(
        style: style,
        children: [
          for (int i = 0; i < items.length - 1; i++) ...[
            TextSpan(
              text: items.keys.elementAt(i),
              style: items.values.elementAt(i) ? highlightStyle : null,
            ),
            spacing,
          ],
          TextSpan(
            text: items.keys.last,
            style: items.values.last ? highlightStyle : null,
          ),
        ],
      ),
    );
  }
}

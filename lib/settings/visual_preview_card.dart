import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';

class VisualPreviewCard extends StatelessWidget {
  const VisualPreviewCard({
    required this.name,
    required this.active,
    required this.child,
    required this.onTap,
    required this.scheme,
  });

  final String name;
  final bool active;
  final Widget child;
  final void Function() onTap;

  /// The color scheme that should be used.
  /// If `null`, the current theme will be used.
  final ColorScheme? scheme;

  @override
  Widget build(BuildContext context) {
    final scheme = this.scheme ?? Theme.of(context).colorScheme;
    final borderWidth = active ? 3.0 : 1.0;
    final borderColor = active ? scheme.primary : scheme.surfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 170,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: scheme.background,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: Consts.borderRadiusMin,
              ),
              child: child,
            ),
            const Spacer(),
            Text(name),
          ],
        ),
      ),
    );
  }
}

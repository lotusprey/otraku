import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';

class ChipGrid extends StatelessWidget {
  const ChipGrid({required this.title, required this.children, required this.onEdit, this.onClear});

  final String title;
  final List<Widget> children;
  final void Function() onEdit;
  final void Function()? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: .min,
      children: [
        Row(
          children: [
            Text(title),
            const Spacer(),
            if (onClear != null && children.isNotEmpty)
              SizedBox(
                height: 35,
                child: IconButton(
                  key: const ValueKey('clear'),
                  icon: const Icon(Ionicons.close_outline),
                  tooltip: l10n.actionClear,
                  onPressed: onClear!,
                  color: ColorScheme.of(context).onSurface,
                  padding: const .symmetric(horizontal: Theming.offset),
                ),
              ),
            SizedBox(
              height: 35,
              child: IconButton(
                icon: const Icon(Ionicons.add_circle_outline),
                tooltip: l10n.actionEdit,
                onPressed: onEdit,
                color: ColorScheme.of(context).onSurface,
                padding: const .symmetric(horizontal: Theming.offset),
              ),
            ),
          ],
        ),
        children.isNotEmpty
            ? Wrap(spacing: 5, children: children)
            : SizedBox(
                height: Theming.minTapTarget,
                child: Center(
                  child: Text(l10n.noResults, style: TextTheme.of(context).labelMedium),
                ),
              ),
      ],
    );
  }
}

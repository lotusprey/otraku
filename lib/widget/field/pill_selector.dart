import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';

class PillSelector extends StatelessWidget {
  const PillSelector({
    required this.selected,
    required this.items,
    required this.onTap,
    this.maxWidth = double.infinity,
    this.scrollCtrl,
  });

  final int selected;
  final List<({Widget title, Widget? subtitle})> items;
  final void Function(int) onTap;
  final double maxWidth;
  final ScrollController? scrollCtrl;

  /// Approximation for a needed base height to display its contents.
  /// Used for calculating the initial size of sheets.
  static double expectedMinHeight(int itemCount) =>
      (Theming.minTapTarget + Theming.offset / 2) * itemCount +
      Theming.offset * 2;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ListView.separated(
        controller: scrollCtrl,
        padding: MediaQuery.paddingOf(context).add(Theming.paddingAll),
        itemCount: items.length,
        separatorBuilder: (context, _) => const SizedBox(
          height: Theming.offset / 2,
        ),
        itemBuilder: (context, i) => Material(
          shape: const StadiumBorder(),
          color: i == selected
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => onTap(i),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: Theming.minTapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Theming.offset * 1.5,
                  vertical: Theming.offset * 0.5,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _ItemContent(items[i]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemContent extends StatelessWidget {
  const _ItemContent(this.item);

  final ({Widget title, Widget? subtitle}) item;

  @override
  Widget build(BuildContext context) {
    var content = item.title;

    if (item.subtitle != null) {
      content = Row(
        children: [
          Expanded(child: content),
          const SizedBox(width: Theming.offset / 2),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.labelMedium!,
            child: item.subtitle!,
          ),
        ],
      );
    }

    return content;
  }
}

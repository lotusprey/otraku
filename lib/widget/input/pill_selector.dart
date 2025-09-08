import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';

class PillSelector extends StatelessWidget {
  const PillSelector({
    required this.selected,
    required this.items,
    required this.onTap,
    this.maxWidth = double.infinity,
    this.shrinkWrap = false,
    this.scrollCtrl,
  });

  final int? selected;
  final List<Widget> items;
  final void Function(int) onTap;
  final double maxWidth;
  final bool shrinkWrap;
  final ScrollController? scrollCtrl;

  /// Approximation for a needed base height to display its contents.
  /// Can be used to calculate the initial size of sheets.
  static double expectedMinHeight(int itemCount) =>
      (Theming.minTapTarget + Theming.offset / 2) * itemCount + Theming.offset * 2;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ListView.separated(
        controller: scrollCtrl,
        shrinkWrap: shrinkWrap,
        padding: MediaQuery.paddingOf(context).add(Theming.paddingAll),
        itemCount: items.length,
        separatorBuilder: (context, _) => const SizedBox(
          height: Theming.offset / 2,
        ),
        itemBuilder: (context, i) => Material(
          shape: const StadiumBorder(),
          color: i == selected ? ColorScheme.of(context).secondaryContainer : null,
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
                  child: items[i],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

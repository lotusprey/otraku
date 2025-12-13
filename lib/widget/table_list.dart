import 'package:flutter/material.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';

class TableList extends StatelessWidget {
  const TableList(this.items, {required this.highContrast});

  final List<(String, String)> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return CardExtension.highContrast(highContrast)(
      child: Padding(
        padding: const .symmetric(vertical: Theming.offset),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          padding: .zero,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, _) => const Divider(),
          itemBuilder: (context, i) => Row(
            children: [
              const SizedBox(width: Theming.offset),
              Text(items[i].$1),
              const SizedBox(width: Theming.offset),
              Expanded(
                child: GestureDetector(
                  behavior: .opaque,
                  onTap: () => SnackBarExtension.copy(context, items[i].$2),
                  child: Text(items[i].$2, textAlign: .end),
                ),
              ),
              const SizedBox(width: Theming.offset),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverTableList extends StatelessWidget {
  const SliverTableList(this.items, {required this.highContrast});

  final List<(String, String)> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SliverToBoxAdapter();

    final colorScheme = ColorScheme.of(context);

    return DecoratedSliver(
      decoration: BoxDecoration(
        borderRadius: Theming.borderRadiusSmall,
        color: highContrast ? null : colorScheme.surfaceContainerLow,
        border: highContrast ? .all(color: colorScheme.outlineVariant) : null,
      ),
      sliver: SliverPadding(
        padding: const .symmetric(vertical: Theming.offset),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (context, _) => const Divider(),
          itemBuilder: (context, i) => Row(
            children: [
              const SizedBox(width: Theming.offset),
              Text(items[i].$1),
              const SizedBox(width: Theming.offset),
              Expanded(
                child: GestureDetector(
                  behavior: .opaque,
                  onTap: () => SnackBarExtension.copy(context, items[i].$2),
                  child: Text(items[i].$2, textAlign: .end),
                ),
              ),
              const SizedBox(width: Theming.offset),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:otraku/util/toast.dart';

class TableList extends StatelessWidget {
  const TableList(this.items);

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (context, _) => const Divider(),
          itemBuilder: (context, i) => Row(
            children: [
              const SizedBox(width: 10),
              Text(items[i].$1),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Toast.copy(context, items[i].$2),
                  child: Text(items[i].$2, textAlign: TextAlign.end),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/widget/input/pill_selector.dart';
import 'package:otraku/widget/swipe_switcher.dart';
import 'package:otraku/widget/sheets.dart';

class CollectionFloatingAction extends StatelessWidget {
  CollectionFloatingAction(this.tag) : super(key: Key('${tag.userId}${tag.ofAnime}'));

  final CollectionTag tag;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final collection = ref.watch(
          collectionProvider(tag).select((s) => s.unwrapPrevious().value),
        );

        return switch (collection) {
          null => const SizedBox(),
          PreviewCollection _ => FloatingActionButton(
            tooltip: 'Load Entire Collection',
            child: const Icon(Ionicons.enter_outline),
            onPressed: () => ref.read(homeProvider.notifier).expandCollection(tag.ofAnime),
          ),
          FullCollection c => _fullCollectionActionButton(context, ref, c.lists, c.index),
        };
      },
    );
  }

  Widget _fullCollectionActionButton(
    BuildContext context,
    WidgetRef ref,
    List<EntryList> lists,
    int index,
  ) {
    final items = buildFullCollectionSelectionItems(context, lists);

    return FloatingActionButton(
      tooltip: 'Lists',
      onPressed: () {
        showSheet(
          context,
          SimpleSheet(
            initialHeight: PillSelector.expectedMinHeight(lists.length),
            builder: (context, scrollCtrl) => PillSelector(
              scrollCtrl: scrollCtrl,
              selected: index + 1,
              items: items,
              onTap: (index) {
                ref.read(collectionProvider(tag).notifier).changeIndex(index - 1);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: SwipeSwitcher(
        index: index + 1,
        children: List.filled(lists.length + 1, const Icon(Ionicons.menu_outline)),
        onChanged: (index) => ref.read(collectionProvider(tag).notifier).changeIndex(index - 1),
      ),
    );
  }
}

List<Widget> buildFullCollectionSelectionItems(BuildContext context, List<EntryList> lists) {
  final listItems = [
    (name: 'All', count: lists.fold(0, (v, l) => v + l.entries.length).toString()),
    ...lists.map((l) => (name: l.name, count: l.entries.length.toString())),
  ];

  final listItemToWidget = (({String name, String count}) item) => Row(
    spacing: 5,
    children: [
      Expanded(child: Text(item.name)),
      Text(item.count, style: TextTheme.of(context).labelMedium),
    ],
  );

  return listItems.map(listItemToWidget).toList();
}

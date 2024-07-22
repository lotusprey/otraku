import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scaffold_extension.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class CollectionFloatingAction extends StatelessWidget {
  CollectionFloatingAction(this.tag)
      : super(key: Key('${tag.userId}${tag.ofAnime}'));

  final CollectionTag tag;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final collection = ref.watch(
          collectionProvider(tag).select((s) => s.unwrapPrevious().valueOrNull),
        );

        return switch (collection) {
          null => const SizedBox(),
          PreviewCollection _ => FloatingActionButton(
              tooltip: 'Load Entire Collection',
              child: const Icon(Ionicons.enter_outline),
              onPressed: () => ref.read(homeProvider.notifier).expandCollection(
                    tag.ofAnime,
                  ),
            ),
          FullCollection c => c.lists.length < 2
              ? const SizedBox()
              : _fullCollectionActionButton(context, ref, c.lists, c.index),
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
    return FloatingActionButton(
      tooltip: 'Lists',
      onPressed: () {
        showSheet(
          context,
          SimpleSheet.list([
            for (int i = 0; i < lists.length; i++)
              ListTile(
                title: Text(lists[i].name),
                selected: i == index,
                trailing: Text(lists[i].entries.length.toString()),
                onTap: () {
                  ref.read(collectionProvider(tag).notifier).changeIndex(i);
                  Navigator.pop(context);
                },
              ),
          ]),
        );
      },
      child: DraggableIcon(
        icon: Ionicons.menu_outline,
        onSwipe: (goRight) {
          if (goRight) {
            if (index < lists.length - 1) {
              index++;
            } else {
              index = 0;
            }
          } else {
            if (index > 0) {
              index--;
            } else {
              index = lists.length - 1;
            }
          }

          ref.read(collectionProvider(tag).notifier).changeIndex(index);
          return null;
        },
      ),
    );
  }
}

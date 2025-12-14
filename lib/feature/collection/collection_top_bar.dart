import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/collection/collection_filter_provider.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/feature/collection/collection_filter_view.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/debounce.dart';
import 'package:otraku/widget/input/search_field.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/sheets.dart';

class CollectionTopBarTrailingContent extends StatelessWidget {
  const CollectionTopBarTrailingContent(this.tag, this.focusNode);

  final CollectionTag tag;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final filter = ref.watch(collectionFilterProvider(tag));

        final filterIcon = IconButton(
          tooltip: 'Filter',
          icon: const Icon(Ionicons.funnel_outline),
          onPressed: () => showSheet(
            context,
            CollectionFilterView(
              tag: tag,
              filter: filter.mediaFilter,
              onChanged: (mediaFilter) => ref
                  .read(collectionFilterProvider(tag).notifier)
                  .update((s) => s.copyWith(mediaFilter: mediaFilter)),
            ),
          ),
        );

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: SearchField(
                  debounce: Debounce(),
                  focusNode: focusNode,
                  hint: ref.watch(collectionProvider(tag).select((s) => s.value?.listName ?? '')),
                  value: filter.search,
                  onChanged: (search) => ref
                      .read(collectionFilterProvider(tag).notifier)
                      .update((s) => s.copyWith(search: search)),
                ),
              ),
              IconButton(
                tooltip: 'Random',
                icon: const Icon(Ionicons.shuffle_outline),
                onPressed: () {
                  final lists = ref.read(collectionEntriesProvider(tag));
                  if (lists.isEmpty) {
                    ConfirmationDialog.show(context, title: 'No entries');
                    return;
                  }

                  final list = lists[Random().nextInt(lists.length)];
                  if (list.entries.isEmpty) {
                    ConfirmationDialog.show(context, title: 'No entries');
                    return;
                  }

                  final entry = list.entries[Random().nextInt(list.entries.length)];
                  context.push(Routes.media(entry.mediaId, entry.imageUrl));
                },
              ),
              if (filter.mediaFilter.isActive)
                Badge(
                  smallSize: 10,
                  alignment: Alignment.topLeft,
                  backgroundColor: ColorScheme.of(context).primary,
                  child: filterIcon,
                )
              else
                filterIcon,
            ],
          ),
        );
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/collection/collection_filter_provider.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/feature/filter/filter_collection_view.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/widget/debounce.dart';
import 'package:otraku/widget/fields/search_field.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';

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
            FilterCollectionView(
              ofAnime: tag.ofAnime,
              ofViewer: tag.userId == Persistence().id,
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
                  hint: ref.watch(collectionProvider(tag).select(
                    (s) => s.valueOrNull?.listName ?? '',
                  )),
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
                  final entries =
                      ref.read(collectionEntriesProvider(tag)).valueOrNull ??
                          const [];

                  if (entries.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const ConfirmationDialog(title: 'No Entries'),
                    );

                    return;
                  }

                  final e = entries[Random().nextInt(entries.length)];
                  context.push(Routes.media(e.mediaId, e.imageUrl));
                },
              ),
              if (filter.mediaFilter.isActive)
                Badge(
                  smallSize: 10,
                  alignment: Alignment.topLeft,
                  backgroundColor: Theme.of(context).colorScheme.primary,
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

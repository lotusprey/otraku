import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scaffold_extension.dart';
import 'package:otraku/feature/collection/collection_floating_action.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/filter/filter_collection_view.dart';
import 'package:otraku/feature/filter/filter_discover_model.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/toast.dart';
import 'package:otraku/widget/fields/search_field.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/collection/collection_filter_provider.dart';
import 'package:otraku/feature/collection/collection_grid.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/feature/collection/collection_list.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/feature/media/media_models.dart';

class CollectionView extends StatefulWidget {
  const CollectionView(this.userId, this.ofAnime);

  final int userId;
  final bool ofAnime;

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tag = (userId: widget.userId, ofAnime: widget.ofAnime);
    return ScaffoldExtension.expanded(
      floatingActionConfig: (
        scrollCtrl: _ctrl,
        actions: [CollectionFloatingAction(tag)],
      ),
      child: CollectionSubview(tag: tag, scrollCtrl: _ctrl, focusNode: null),
    );
  }
}

class CollectionSubview extends StatelessWidget {
  const CollectionSubview({
    required this.tag,
    required this.scrollCtrl,
    required this.focusNode,
    super.key,
  });

  final CollectionTag tag;
  final ScrollController scrollCtrl;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      topBar: TopBar(
        trailing: [_TopBarContent(tag, focusNode)],
      ),
      child: Scrollbar(
        controller: scrollCtrl,
        child: Consumer(
          builder: (context, ref, _) {
            return ConstrainedView(
              child: CustomScrollView(
                physics: Theming.bouncyPhysics,
                controller: scrollCtrl,
                slivers: [
                  SliverRefreshControl(
                    onRefresh: () => ref.invalidate(collectionProvider(tag)),
                  ),
                  _Content(tag),
                  const SliverFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBarContent extends StatelessWidget {
  const _TopBarContent(this.tag, this.focusNode);

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

class _Content extends StatefulWidget {
  const _Content(this.tag);

  final CollectionTag tag;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          collectionEntriesProvider(widget.tag),
          (_, s) => s.whenOrNull(
            error: (error, _) => Toast.show(context, error.toString()),
          ),
        );

        return ref
            .watch(collectionEntriesProvider(widget.tag))
            .unwrapPrevious()
            .when(
              loading: () => const SliverFillRemaining(
                child: Center(child: Loader()),
              ),
              error: (_, __) => const SliverFillRemaining(
                child: Center(child: Text('No results')),
              ),
              data: (data) {
                final isViewer = widget.tag.userId == Persistence().id;

                if (data.isEmpty) {
                  if (!isViewer) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No results')),
                    );
                  }

                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('No results'),
                          TextButton(
                            onPressed: () => _searchGlobally(ref),
                            child: const Text('Search Globally'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final onProgressUpdated = isViewer
                    ? ref
                        .read(collectionProvider(widget.tag).notifier)
                        .saveEntryProgress
                    : null;

                final collectionIsExpanded = !isViewer ||
                    ref.watch(homeProvider.select(
                      (s) => widget.tag.ofAnime
                          ? s.didExpandAnimeCollection
                          : s.didExpandMangaCollection,
                    ));

                if (collectionIsExpanded &&
                        Persistence().collectionItemView == 1 ||
                    !collectionIsExpanded &&
                        Persistence().collectionPreviewItemView == 1) {
                  return CollectionGrid(
                    items: data,
                    onProgressUpdated: onProgressUpdated,
                  );
                }

                return CollectionList(
                  items: data,
                  onProgressUpdated: onProgressUpdated,
                  scoreFormat: ref.watch(
                    collectionProvider(widget.tag).select(
                      (s) =>
                          s.valueOrNull?.scoreFormat ??
                          ScoreFormat.point10Decimal,
                    ),
                  ),
                );
              },
            );
      },
    );
  }

  void _searchGlobally(WidgetRef ref) {
    final tag = widget.tag;
    final collectionFilter = ref.read(collectionFilterProvider(tag));

    ref.read(discoverFilterProvider.notifier).update((f) => f.copyWith(
          type: tag.ofAnime ? DiscoverType.anime : DiscoverType.manga,
          search: collectionFilter.search,
          mediaFilter: DiscoverMediaFilter.fromCollection(
            filter: collectionFilter.mediaFilter,
            ofAnime: tag.ofAnime,
          ),
        ));

    context.go(Routes.home(HomeTab.discover));

    ref
        .read(collectionFilterProvider(tag).notifier)
        .update((_) => CollectionFilter(tag.ofAnime));
  }
}

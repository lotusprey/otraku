import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/scaffold_extension.dart';
import 'package:otraku/feature/collection/collection_floating_action.dart';
import 'package:otraku/feature/collection/collection_top_bar.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/filter/filter_discover_model.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/collection/collection_filter_provider.dart';
import 'package:otraku/feature/collection/collection_grid.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/feature/collection/collection_list.dart';
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
      topBar: TopBar(trailing: [CollectionTopBarTrailingContent(tag, null)]),
      floatingActionConfig: (
        scrollCtrl: _ctrl,
        actions: [CollectionFloatingAction(tag)],
      ),
      child: CollectionSubview(tag: tag, scrollCtrl: _ctrl),
    );
  }
}

class CollectionSubview extends StatelessWidget {
  const CollectionSubview({
    required this.tag,
    required this.scrollCtrl,
    super.key,
  });

  final CollectionTag tag;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
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
            error: (error, _) =>
                SnackBarExtension.show(context, error.toString()),
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

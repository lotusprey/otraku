import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:otraku/widget/fields/pill_selector.dart';
import 'package:otraku/widget/layouts/adaptive_scaffold.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/feature/collection/collection_list.dart';
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

    return AdaptiveScaffold(
      topBar: TopBar(trailing: [CollectionTopBarTrailingContent(tag, null)]),
      floatingAction: HidingFloatingActionButton(
        key: const Key('lists'),
        showOnlyWhenCompact: true,
        scrollCtrl: _ctrl,
        child: CollectionFloatingAction(tag),
      ),
      builder: (context, compact) => CollectionSubview(
        tag: tag,
        scrollCtrl: _ctrl,
        compact: compact,
      ),
    );
  }
}

class CollectionSubview extends StatelessWidget {
  const CollectionSubview({
    required this.tag,
    required this.scrollCtrl,
    required this.compact,
    super.key,
  });

  final CollectionTag tag;
  final ScrollController scrollCtrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          collectionProvider(tag),
          (_, s) => s.whenOrNull(
            error: (error, _) => SnackBarExtension.show(
              context,
              error.toString(),
            ),
          ),
        );

        return ref.watch(collectionProvider(tag)).unwrapPrevious().when(
              loading: () => const Center(child: Loader()),
              error: (_, __) => const Center(child: Text('No results')),
              data: (data) {
                final content = Scrollbar(
                  controller: scrollCtrl,
                  child: ConstrainedView(
                    child: CustomScrollView(
                      physics: Theming.bouncyPhysics,
                      controller: scrollCtrl,
                      slivers: [
                        SliverRefreshControl(
                          onRefresh: () => ref.invalidate(
                            collectionProvider(tag),
                          ),
                        ),
                        _Content(tag, data),
                        const SliverFooter(),
                      ],
                    ),
                  ),
                );

                if (compact) return content;

                return switch (data) {
                  PreviewCollection _ => content,
                  FullCollection c => Row(
                      children: [
                        PillSelector(
                          maxWidth: 200,
                          selected: c.index,
                          onTap: (i) => ref
                              .read(collectionProvider(tag).notifier)
                              .changeIndex(i),
                          items: data.lists
                              .map((l) => (
                                    title: Text(l.name),
                                    subtitle: Text(l.entries.length.toString()),
                                  ))
                              .toList(),
                        ),
                        Expanded(child: content)
                      ],
                    ),
                };
              },
            );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.tag, this.collection);

  final CollectionTag tag;
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final entries = ref.watch(collectionEntriesProvider(tag));

        final isViewer = tag.userId == Persistence().id;

        if (entries.isEmpty) {
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
                    onPressed: () => _searchGlobally(context, ref),
                    child: const Text('Search Globally'),
                  ),
                ],
              ),
            ),
          );
        }

        final onProgressUpdated = isViewer
            ? ref.read(collectionProvider(tag).notifier).saveEntryProgress
            : null;

        final collectionIsExpanded = switch (collection) {
          PreviewCollection _ => false,
          FullCollection _ => true,
        };

        if (collectionIsExpanded && Persistence().collectionItemView == 1 ||
            !collectionIsExpanded &&
                Persistence().collectionPreviewItemView == 1) {
          return CollectionGrid(
            items: entries,
            onProgressUpdated: onProgressUpdated,
          );
        }

        return CollectionList(
          items: entries,
          onProgressUpdated: onProgressUpdated,
          scoreFormat: ref.watch(
            collectionProvider(tag).select(
              (s) => s.valueOrNull?.scoreFormat ?? ScoreFormat.point10Decimal,
            ),
          ),
        );
      },
    );
  }

  void _searchGlobally(BuildContext context, WidgetRef ref) {
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

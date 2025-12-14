import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/collection/collection_floating_action.dart';
import 'package:otraku/feature/collection/collection_top_bar.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/collection/collection_filter_provider.dart';
import 'package:otraku/feature/collection/collection_grid.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/widget/input/pill_selector.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/feature/collection/collection_list.dart';

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
    final formFactor = Theming.of(context).formFactor;

    return AdaptiveScaffold(
      topBar: TopBar(trailing: [CollectionTopBarTrailingContent(tag, null)]),
      floatingAction: formFactor == .phone
          ? HidingFloatingActionButton(
              key: const Key('lists'),
              scrollCtrl: _ctrl,
              child: CollectionFloatingAction(tag),
            )
          : null,
      child: CollectionSubview(tag: tag, scrollCtrl: _ctrl, formFactor: formFactor),
    );
  }
}

class CollectionSubview extends StatelessWidget {
  const CollectionSubview({
    required this.tag,
    required this.scrollCtrl,
    required this.formFactor,
    super.key,
  });

  final CollectionTag? tag;
  final ScrollController scrollCtrl;
  final FormFactor formFactor;

  @override
  Widget build(BuildContext context) {
    if (tag == null) {
      return const Center(
        child: Padding(
          padding: Theming.paddingAll,
          child: Text('Log in from the profile tab to view your collections', textAlign: .center),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          collectionProvider(tag!),
          (_, s) =>
              s.whenOrNull(error: (error, _) => SnackBarExtension.show(context, error.toString())),
        );

        return ref
            .watch(collectionProvider(tag!))
            .unwrapPrevious()
            .when(
              loading: () => const Center(child: Loader()),
              error: (_, _) => CustomScrollView(
                physics: Theming.bouncyPhysics,
                slivers: [
                  SliverRefreshControl(onRefresh: () => ref.invalidate(collectionProvider(tag!))),
                  const SliverFillRemaining(child: Center(child: Text('Failed to load'))),
                ],
              ),
              data: (data) {
                final content = Scrollbar(
                  controller: scrollCtrl,
                  child: ConstrainedView(
                    child: CustomScrollView(
                      physics: Theming.bouncyPhysics,
                      controller: scrollCtrl,
                      slivers: [
                        SliverRefreshControl(
                          onRefresh: () => ref.invalidate(collectionProvider(tag!)),
                        ),
                        _Content(tag!, data),
                        const SliverFooter(),
                      ],
                    ),
                  ),
                );

                if (formFactor == .phone) return content;

                return switch (data) {
                  PreviewCollection _ => content,
                  FullCollection c => Row(
                    children: [
                      PillSelector(
                        maxWidth: 200,
                        selected: c.index + 1,
                        items: buildFullCollectionSelectionItems(context, data.lists),
                        onTap: (i) =>
                            ref.read(collectionProvider(tag!).notifier).changeIndex(i - 1),
                      ),
                      Expanded(child: content),
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
        final lists = ref.watch(collectionEntriesProvider(tag));

        final options = ref.watch(persistenceProvider.select((s) => s.options));
        final isViewer = ref.watch(viewerIdProvider) == tag.userId;

        if (lists.isEmpty) {
          if (!isViewer) {
            return const SliverFillRemaining(child: Center(child: Text('No results')));
          }

          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: .min,
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

        // TODO fix indexing
        final (collectionIsExpanded, listIndex) = switch (collection) {
          PreviewCollection _ => (false, 0),
          FullCollection c => (true, c.index),
        };

        final useSimpleGrid =
            collectionIsExpanded && options.collectionItemView == .simple ||
            !collectionIsExpanded && options.collectionPreviewItemView == .simple;

        if (!collectionIsExpanded || listIndex > -1) {
          return useSimpleGrid
              ? CollectionGrid(
                  items: lists[listIndex].entries,
                  onProgressUpdated: onProgressUpdated,
                  highContrast: options.highContrast,
                )
              : CollectionList(
                  items: lists[listIndex].entries,
                  onProgressUpdated: onProgressUpdated,
                  scoreFormat: ref.watch(
                    collectionProvider(tag).select((s) => s.value?.scoreFormat ?? .point10Decimal),
                  ),
                  highContrast: options.highContrast,
                );
        }

        return SliverMainAxisGroup(
          slivers: [
            for (final l in lists) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const .only(bottom: Theming.offset),
                  child: Text(l.name, style: TextTheme.of(context).titleMedium),
                ),
              ),
              useSimpleGrid
                  ? CollectionGrid(
                      items: l.entries,
                      onProgressUpdated: onProgressUpdated,
                      highContrast: options.highContrast,
                    )
                  : CollectionList(
                      items: l.entries,
                      onProgressUpdated: onProgressUpdated,
                      scoreFormat: ref.watch(
                        collectionProvider(
                          tag,
                        ).select((s) => s.value?.scoreFormat ?? .point10Decimal),
                      ),
                      highContrast: options.highContrast,
                    ),
            ],
          ],
        );
      },
    );
  }

  void _searchGlobally(BuildContext context, WidgetRef ref) {
    final collectionFilter = ref.read(collectionFilterProvider(tag));
    final sort = ref.read(persistenceProvider).discoverMediaFilter.sort;

    ref
        .read(discoverFilterProvider.notifier)
        .update(
          (f) => f.copyWith(
            type: tag.ofAnime ? .anime : .manga,
            search: collectionFilter.search,
            mediaFilter: DiscoverMediaFilter.fromCollection(
              filter: collectionFilter.mediaFilter,
              sort: sort,
              ofAnime: tag.ofAnime,
            ),
          ),
        );

    context.go(Routes.home(.discover));
    ref.invalidate(collectionFilterProvider(tag));
  }
}

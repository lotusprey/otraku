import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/collection/collection_floating_action.dart';
import 'package:otraku/feature/collection/collection_top_bar.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/filter/filter_discover_model.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/collection/collection_filter_provider.dart';
import 'package:otraku/feature/collection/collection_grid.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/widget/field/pill_selector.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/loaders.dart';
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
      (context, compact) => ScaffoldConfig(
        topBar: TopBar(trailing: [CollectionTopBarTrailingContent(tag, null)]),
        floatingAction: compact
            ? HidingFloatingActionButton(
                key: const Key('lists'),
                scrollCtrl: _ctrl,
                child: CollectionFloatingAction(tag),
              )
            : null,
        child: CollectionSubview(
          tag: tag,
          scrollCtrl: _ctrl,
          compact: compact,
        ),
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

  final CollectionTag? tag;
  final ScrollController scrollCtrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (tag == null) {
      return const Center(
        child: Padding(
          padding: Theming.paddingAll,
          child: Text(
            'Log in from the profile tab to view your collections',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final listToWidget = (EntryList l) => Row(
          children: [
            Expanded(child: Text(l.name)),
            const SizedBox(width: Theming.offset / 2),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.labelMedium!,
              child: Text(l.entries.length.toString()),
            ),
          ],
        );

    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          collectionProvider(tag!),
          (_, s) => s.whenOrNull(
            error: (error, _) => SnackBarExtension.show(
              context,
              error.toString(),
            ),
          ),
        );

        return ref.watch(collectionProvider(tag!)).unwrapPrevious().when(
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
                            collectionProvider(tag!),
                          ),
                        ),
                        _Content(tag!, data),
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
                          items: data.lists.map(listToWidget).toList(),
                          onTap: (i) => ref
                              .read(collectionProvider(tag!).notifier)
                              .changeIndex(i),
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

        final options = ref.watch(persistenceProvider.select((s) => s.options));
        final isViewer = ref.watch(viewerIdProvider) == tag.userId;

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

        if (collectionIsExpanded &&
                options.collectionItemView == CollectionItemView.simple ||
            !collectionIsExpanded &&
                options.collectionPreviewItemView ==
                    CollectionItemView.simple) {
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
    final options = ref.read(persistenceProvider).options;

    ref.read(discoverFilterProvider.notifier).update((f) => f.copyWith(
          type: tag.ofAnime ? DiscoverType.anime : DiscoverType.manga,
          search: collectionFilter.search,
          mediaFilter: DiscoverMediaFilter.fromCollection(
            filter: collectionFilter.mediaFilter,
            sort: options.defaultDiscoverSort,
            ofAnime: tag.ofAnime,
          ),
        ));

    context.go(Routes.home(HomeTab.discover));
    ref.invalidate(collectionFilterProvider(tag));
  }
}

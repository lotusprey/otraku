import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/fields/search_field.dart';
import 'package:otraku/modules/collection/collection_entries_provider.dart';
import 'package:otraku/modules/collection/collection_filter_provider.dart';
import 'package:otraku/modules/collection/collection_grid.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/collection/collection_provider.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/filter/filter_view.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/modules/collection/collection_list.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/media/media_constants.dart';

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
    return PageScaffold(
      child: CollectionSubView(
        tag: (userId: widget.userId, ofAnime: widget.ofAnime),
        scrollCtrl: _ctrl,
        focusNode: null,
      ),
    );
  }
}

class CollectionSubView extends StatelessWidget {
  const CollectionSubView({
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
        canPop: tag.userId != Options().id,
        trailing: [_TopBarContent(tag, focusNode)],
      ),
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_ActionButton(tag)],
      ),
      child: Consumer(
        builder: (context, ref, _) {
          return ConstrainedView(
            child: CustomScrollView(
              physics: Consts.physics,
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

class _TopBarContent extends StatelessWidget {
  const _TopBarContent(this.tag, this.focusNode);

  final CollectionTag tag;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
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
                  value: ref.watch(
                    collectionFilterProvider(tag).select((s) => s.search),
                  ),
                  onChanged: (search) => ref
                      .read(collectionFilterProvider(tag).notifier)
                      .update((s) => s.copyWith(search: search)),
                ),
              ),
              TopBarIcon(
                tooltip: 'Random',
                icon: Ionicons.shuffle_outline,
                onTap: () {
                  final entries =
                      ref.read(collectionEntriesProvider(tag)).valueOrNull ??
                          const [];

                  if (entries.isEmpty) {
                    showPopUp(
                      context,
                      const ConfirmationDialog(title: 'No Entries'),
                    );

                    return;
                  }

                  final e = entries[Random().nextInt(entries.length)];
                  context.push(Routes.media(e.mediaId, e.imageUrl));
                },
              ),
              TopBarIcon(
                tooltip: 'Filter',
                icon: Ionicons.funnel_outline,
                onTap: () => showSheet(
                  context,
                  CollectionFilterView(
                    ofAnime: tag.ofAnime,
                    ofViewer: tag.userId == Options().id,
                    filter: ref.read(collectionFilterProvider(tag)).mediaFilter,
                    onChanged: (mediaFilter) => ref
                        .read(collectionFilterProvider(tag).notifier)
                        .update((s) => s.copyWith(mediaFilter: mediaFilter)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.tag);

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
          PreviewCollection _ => ActionButton(
              tooltip: 'Load Entire Collection',
              icon: Ionicons.enter_outline,
              onTap: () => ref.read(homeProvider).expandCollection(
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
    return ActionButton(
      tooltip: 'Lists',
      icon: Ionicons.menu_outline,
      onTap: () {
        final theme = Theme.of(context);

        showSheet(
          context,
          GradientSheet([
            for (int i = 0; i < lists.length; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(collectionProvider(tag).notifier).changeIndex(i);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        lists[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: i != index
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                      ),
                    ),
                    Text(
                      ' ${lists[i].entries.length}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
          ]),
        );
      },
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
            error: (error, _) => showPopUp(
              context,
              ConfirmationDialog(
                title: 'Failed to load',
                content: error.toString(),
              ),
            ),
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
                final onProgressUpdated = widget.tag.userId == Options().id
                    ? ref
                        .read(collectionProvider(widget.tag).notifier)
                        .saveEntryProgress
                    : null;

                if (Options().collectionItemView == 1) {
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
                          ScoreFormat.POINT_10_DECIMAL,
                    ),
                  ),
                );
              },
            );
      },
    );
  }
}

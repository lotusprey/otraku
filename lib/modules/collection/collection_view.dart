import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/fields/search_field.dart';
import 'package:otraku/modules/collection/collection_grid.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/collection/collection_providers.dart';
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
                  onRefresh: () {
                    final index = ref.read(collectionProvider(tag)).index;

                    final notifier = ref.refresh(collectionProvider(tag));
                    notifier.index = index;
                  },
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
        final notifier = ref.watch(collectionProvider(tag));
        if (notifier.lists.isEmpty) return const SizedBox();

        /// If [entriesProvider] returns an empty list,
        /// the random entry button shouldn't appear.
        final noResults =
            ref.watch(entriesProvider(tag).select((s) => s.isEmpty));

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: SearchField(
                  debounce: Debounce(),
                  focusNode: focusNode,
                  hint: notifier.lists[notifier.index].name,
                  value: ref.watch(
                    collectionFilterProvider(tag).select((s) => s.search),
                  ),
                  onChanged: (search) => ref
                      .read(collectionFilterProvider(tag).notifier)
                      .update((s) => s.copyWith(search: search)),
                ),
              ),
              if (noResults)
                const SizedBox(width: 45)
              else
                TopBarIcon(
                  tooltip: 'Random',
                  icon: Ionicons.shuffle_outline,
                  onTap: () {
                    final entries = ref.read(entriesProvider(tag));
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
        if (ref.watch(collectionProvider(tag).select(
          (s) => s.lists.length < 2,
        ))) {
          return const SizedBox();
        }

        return ActionButton(
          tooltip: 'Lists',
          icon: Ionicons.menu_outline,
          onTap: () {
            final notifier = ref.read(collectionProvider(tag));
            final theme = Theme.of(context);

            showSheet(
              context,
              GradientSheet([
                for (int i = 0; i < notifier.lists.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                      notifier.index = i;
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            notifier.lists[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: i != notifier.index
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                          ),
                        ),
                        Text(
                          ' ${notifier.lists[i].entries.length}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
              ]),
            );
          },
          onSwipe: (goRight) {
            final notifier = ref.read(collectionProvider(tag));

            if (goRight) {
              if (notifier.index < notifier.lists.length - 1) {
                notifier.index++;
              } else {
                notifier.index = 0;
              }
            } else {
              if (notifier.index > 0) {
                notifier.index--;
              } else {
                notifier.index = notifier.lists.length - 1;
              }
            }

            return null;
          },
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
          collectionProvider(widget.tag).select((s) => s.state),
          (_, s) => s.whenOrNull(
            error: (error, _) => showPopUp(
              context,
              ConfirmationDialog(
                title: 'Failed to load collection',
                content: error.toString(),
              ),
            ),
          ),
        );

        final notifier = ref.watch(collectionProvider(widget.tag));
        if (notifier.state.isLoading) {
          return const SliverFillRemaining(child: Center(child: Loader()));
        }

        final entries = ref.watch(entriesProvider(widget.tag));
        if (entries.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No results')),
          );
        }

        void Function(Entry, List<String>)? update;
        if (widget.tag.userId == Options().id) {
          update = (entry, customLists) {
            ref.read(collectionProvider(widget.tag)).updateProgress(
                  mediaId: entry.mediaId,
                  progress: entry.progress,
                  customLists: customLists,
                  listStatus: entry.entryStatus,
                  format: entry.format,
                  sort: ref
                      .read(collectionFilterProvider(widget.tag))
                      .mediaFilter
                      .sort,
                );
          };
        }

        return Options().collectionItemView == 0
            ? CollectionList(
                items: entries,
                scoreFormat: notifier.scoreFormat,
                onProgressUpdate: update,
              )
            : CollectionGrid(
                items: entries,
                onProgressUpdate: update,
              );
      },
    );
  }
}

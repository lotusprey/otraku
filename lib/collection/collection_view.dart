import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_grid.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/collection/collection_providers.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/filter/filter_view.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/collection/collection_list.dart';
import 'package:otraku/filter/filter_search_field.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

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
    final tag = CollectionTag(widget.userId, widget.ofAnime);

    return Consumer(
      child: CollectionSubView(scrollCtrl: _ctrl, tag: tag),
      builder: (context, ref, child) => WillPopScope(
        child: child!,
        onWillPop: () {
          final notifier = ref.read(searchProvider(tag).notifier);
          if (notifier.state == null) return Future.value(true);
          notifier.state = null;
          return Future.value(false);
        },
      ),
    );
  }
}

class CollectionSubView extends StatelessWidget {
  const CollectionSubView({
    required this.tag,
    required this.scrollCtrl,
    super.key,
  });

  final CollectionTag tag;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return PageLayout(
          topBar: PreferredSize(
            preferredSize: const Size.fromHeight(Consts.tapTargetSize),
            child: _TopBar(tag, tag.userId != Options().id),
          ),
          floatingBar: FloatingBar(
            scrollCtrl: scrollCtrl,
            children: [_ActionButton(tag)],
          ),
          child: ConstrainedView(
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
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar(this.tag, this.canPop);

  final CollectionTag tag;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.watch(collectionProvider(tag));
        if (notifier.lists.isEmpty) return TopBar(canPop: canPop);

        /// If [entriesProvider] returns an empty list,
        /// the random entry button shouldn't appear.
        final noResults =
            ref.watch(entriesProvider(tag).select((s) => s.isEmpty));

        return TopBar(
          canPop: canPop,
          items: [
            SearchFilterField(
              title: notifier.lists[notifier.index].name,
              tag: tag,
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

                  Navigator.pushNamed(
                    context,
                    RouteArg.media,
                    arguments: RouteArg(id: e.mediaId, info: e.imageUrl),
                  );
                },
              ),
            TopBarIcon(
              tooltip: 'Filter',
              icon: Ionicons.funnel_outline,
              onTap: () {
                final notifier =
                    ref.read(collectionFilterProvider(tag).notifier);

                showSheet(
                  context,
                  CollectionFilterView(
                    filter: notifier.state,
                    onChanged: (filter) => notifier.state = filter,
                  ),
                );
              },
            ),
          ],
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
              DynamicGradientDragSheet(
                onTap: (i) => notifier.index = i,
                children: [
                  for (int i = 0; i < notifier.lists.length; i++)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            notifier.lists[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: i != notifier.index
                                ? theme.textTheme.headline1
                                : theme.textTheme.headline1?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                          ),
                        ),
                        Text(
                          ' ${notifier.lists[i].entries.length}',
                          style: theme.textTheme.headline3,
                        ),
                      ],
                    ),
                ],
              ),
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
                  sort: ref.read(collectionFilterProvider(widget.tag)).sort,
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
                scoreFormat: notifier.scoreFormat,
                onProgressUpdate: update,
              );
      },
    );
  }
}

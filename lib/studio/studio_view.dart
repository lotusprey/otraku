import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/filter/chip_selector.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/staff/staff_providers.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/studio/studio_providers.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/widgets/grids/tile_item_grid.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class StudioView extends ConsumerStatefulWidget {
  const StudioView(this.id, this.name);

  final int id;
  final String? name;

  @override
  ConsumerState<StudioView> createState() => _StudioViewState();
}

class _StudioViewState extends ConsumerState<StudioView> {
  late final _ctrl = PagedController(loadMore: () {
    ref.read(studioProvider(widget.id).notifier).fetchPage();
  });

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refreshControl = SliverRefreshControl(
      onRefresh: () => ref.invalidate(staffProvider(widget.id)),
    );

    final studio = ref.watch(
      studioProvider(widget.id).select((s) => s.valueOrNull?.studio),
    );

    return PageScaffold(
      child: TabScaffold(
        topBar: const TopBar(),
        floatingBar: FloatingBar(
          scrollCtrl: _ctrl,
          children: [
            if (studio != null) ...[
              _FavoriteButton(studio),
              _FilterButton(widget.id),
            ],
          ],
        ),
        child: ConstrainedView(
          child: Consumer(
            builder: (context, ref, _) {
              ref.listen<AsyncValue>(
                studioProvider(widget.id),
                (_, s) {
                  if (s.hasError) {
                    showPopUp(
                      context,
                      ConfirmationDialog(
                        title: 'Failed to load studio',
                        content: s.error.toString(),
                      ),
                    );
                  }
                },
              );

              final name = studio?.name ?? widget.name;
              final titleWidget = name != null
                  ? SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () => Toast.copy(context, name),
                        child: Hero(
                          tag: widget.id,
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    )
                  : null;

              return ref.watch(studioProvider(widget.id)).unwrapPrevious().when(
                    loading: () => CustomScrollView(
                      physics: Consts.physics,
                      slivers: [
                        refreshControl,
                        if (titleWidget != null) titleWidget,
                        const SliverFillRemaining(
                          child: Center(child: Loader()),
                        ),
                      ],
                    ),
                    error: (_, __) => CustomScrollView(
                      physics: Consts.physics,
                      slivers: [
                        refreshControl,
                        if (titleWidget != null) titleWidget,
                        const SliverFillRemaining(
                          child: Center(child: Text('Failed to load studio')),
                        ),
                      ],
                    ),
                    data: (data) {
                      final items = <Widget>[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            child: Text(
                              '${data.studio.favorites.toString()} favourites',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        )
                      ];
                      final sort =
                          ref.watch(studioFilterProvider(widget.id)).sort;

                      if (sort == MediaSort.START_DATE ||
                          sort == MediaSort.START_DATE_DESC) {
                        for (int i = 0; i < data.categories.length; i++) {
                          items.add(SliverToBoxAdapter(
                            child: Text(
                              data.categories.keys.elementAt(i),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ));

                          final beg = data.categories.values.elementAt(i);
                          final end = i < data.categories.length - 1
                              ? data.categories.values.elementAt(i + 1)
                              : data.media.items.length;

                          items.add(const SliverToBoxAdapter(
                            child: SizedBox(height: 10),
                          ));
                          items.add(
                            TileItemGrid(data.media.items.sublist(beg, end)),
                          );
                          items.add(const SliverToBoxAdapter(
                            child: SizedBox(height: 10),
                          ));
                        }
                      } else {
                        items.add(TileItemGrid(data.media.items));
                      }

                      return CustomScrollView(
                        physics: Consts.physics,
                        controller: _ctrl,
                        slivers: [
                          refreshControl,
                          titleWidget!,
                          ...items,
                          SliverFooter(loading: data.media.hasNext),
                        ],
                      );
                    },
                  );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.data);

  final Studio data;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: widget.data.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.data.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(
          () => widget.data.isFavorite = !widget.data.isFavorite,
        );
        toggleFavoriteStudio(widget.data.id).then((ok) {
          if (!ok) {
            setState(
              () => widget.data.isFavorite = !widget.data.isFavorite,
            );
          }
        });
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            var filter = ref.read(studioFilterProvider(id));

            final sortItems = <String, int>{};
            for (int i = 0; i < MediaSort.values.length; i += 2) {
              String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
              sortItems[key] = i ~/ 2;
            }

            final onDone = (_) =>
                ref.read(studioFilterProvider(id).notifier).state = filter;

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: Consts.tapTargetSize * 5,
                builder: (context, scrollCtrl) => ListView(
                  controller: scrollCtrl,
                  physics: Consts.physics,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  children: [
                    ChipSelector(
                      title: 'Sort',
                      options: MediaSort.values.map((s) => s.label).toList(),
                      selected: filter.sort.index,
                      mustHaveSelected: true,
                      onChanged: (i) => filter = filter.copyWith(
                        sort: MediaSort.values.elementAt(i!),
                      ),
                    ),
                    ChipSelector(
                      title: 'List Presence',
                      options: const ['On List', 'Not on List'],
                      selected: filter.onList == null
                          ? null
                          : filter.onList!
                              ? 0
                              : 1,
                      onChanged: (val) => filter = filter.copyWith(onList: () {
                        if (val == null) return null;
                        return val == 0 ? true : false;
                      }),
                    ),
                    ChipSelector(
                      title: 'Main Studio',
                      options: const ['Is Main', 'Is Not Main'],
                      selected: filter.isMain == null
                          ? null
                          : filter.isMain!
                              ? 0
                              : 1,
                      onChanged: (val) => filter = filter.copyWith(isMain: () {
                        if (val == null) return null;
                        return val == 0 ? true : false;
                      }),
                    ),
                  ],
                ),
              ),
            ).then(onDone);
          },
        );
      },
    );
  }
}

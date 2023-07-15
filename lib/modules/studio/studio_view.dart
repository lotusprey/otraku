import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/studio/studio_models.dart';
import 'package:otraku/modules/studio/studio_providers.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/widgets/grids/tile_item_grid.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';

class StudioView extends ConsumerStatefulWidget {
  const StudioView(this.id, this.name);

  final int id;
  final String? name;

  @override
  ConsumerState<StudioView> createState() => _StudioViewState();
}

class _StudioViewState extends ConsumerState<StudioView> {
  late final _ctrl = PagedController(loadMore: () {
    ref.read(studioProvider(widget.id).notifier).fetch();
  });

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ConstrainedView(
        child: Consumer(
          builder: (context, ref, _) {
            ref.listen<AsyncValue>(
              studioProvider(widget.id).select((s) => s.info),
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

            final studio = ref.watch(studioProvider(widget.id));
            final info = studio.info.valueOrNull;
            final name = info?.name ?? widget.name;
            final items = <Widget>[];
            bool? hasNext;

            studio.media.unwrapPrevious().when(
                  loading: () => items.add(
                    const SliverFillRemaining(child: Center(child: Loader())),
                  ),
                  error: (_, __) => items.add(
                    const SliverFillRemaining(
                      child: Center(child: Text('Failed to load studio')),
                    ),
                  ),
                  data: (data) {
                    hasNext = data.hasNext;

                    if (info != null) {
                      items.add(SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 20,
                          ),
                          child: Text(
                            '${info.favorites.toString()} favourites',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ));
                    }

                    final sort =
                        ref.watch(studioFilterProvider(widget.id)).sort;

                    if (sort != MediaSort.START_DATE &&
                        sort != MediaSort.START_DATE_DESC) {
                      items.add(TileItemGrid(data.items));
                      return;
                    }

                    for (int i = 0; i < studio.categories.length; i++) {
                      items.add(SliverToBoxAdapter(
                        child: Text(
                          studio.categories.keys.elementAt(i),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ));

                      final beg = studio.categories.values.elementAt(i);
                      final end = i < studio.categories.length - 1
                          ? studio.categories.values.elementAt(i + 1)
                          : data.items.length;

                      items.add(
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          sliver: TileItemGrid(data.items.sublist(beg, end)),
                        ),
                      );
                    }
                  },
                );

            return TabScaffold(
              topBar: const TopBar(),
              floatingBar: FloatingBar(
                scrollCtrl: _ctrl,
                children: info != null
                    ? [_FavoriteButton(info), _FilterButton(widget.id)]
                    : const [],
              ),
              child: CustomScrollView(
                physics: Consts.physics,
                controller: hasNext != null ? _ctrl : null,
                slivers: [
                  SliverRefreshControl(
                    onRefresh: () => ref.invalidate(studioProvider(widget.id)),
                  ),
                  if (name != null)
                    SliverToBoxAdapter(
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
                    ),
                  ...items,
                  SliverFooter(loading: hasNext ?? false),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.data);

  final StudioInfo data;

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
                      current: filter.sort.index,
                      mustHaveSelected: true,
                      onChanged: (i) => filter = filter.copyWith(
                        sort: MediaSort.values.elementAt(i!),
                      ),
                    ),
                    ChipSelector(
                      title: 'List Presence',
                      options: const ['On List', 'Not on List'],
                      current: filter.onList == null
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
                      current: filter.isMain == null
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

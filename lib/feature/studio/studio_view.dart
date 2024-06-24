import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/studio/studio_filter_provider.dart';
import 'package:otraku/feature/studio/studio_model.dart';
import 'package:otraku/feature/studio/studio_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/grids/tile_item_grid.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/util/toast.dart';

class StudioView extends ConsumerStatefulWidget {
  const StudioView(this.id, this.name);

  final int id;
  final String? name;

  @override
  ConsumerState<StudioView> createState() => _StudioViewState();
}

class _StudioViewState extends ConsumerState<StudioView> {
  late final _ctrl = PagedController(loadMore: () {
    ref.read(studioMediaProvider(widget.id).notifier).fetch();
  });

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Consumer(
        builder: (context, ref, _) {
          ref.listen<AsyncValue>(
            studioProvider(widget.id),
            (_, s) {
              if (s.hasError) {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    title: 'Failed to load studio',
                    content: s.error.toString(),
                  ),
                );
              }
            },
          );

          final studio = ref.watch(studioProvider(widget.id)).valueOrNull;
          final studioMedia = ref.watch(studioMediaProvider(widget.id));
          final name = studio?.name ?? widget.name;
          final items = <Widget>[
            if (studio != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: Theming.offset,
                    bottom: 20,
                  ),
                  child: Text(
                    '${studio.favorites.toString()} favourites',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
          ];
          bool? hasNext;

          studioMedia.unwrapPrevious().when(
                loading: () => items.add(
                  const SliverFillRemaining(child: Center(child: Loader())),
                ),
                error: (_, __) => items.add(
                  const SliverFillRemaining(
                    child: Center(child: Text('Failed to load studio')),
                  ),
                ),
                data: (data) {
                  hasNext = data.media.hasNext;

                  final sort = ref.watch(studioFilterProvider(widget.id)).sort;

                  if (sort != MediaSort.startDate &&
                      sort != MediaSort.startDateDesc) {
                    items.add(TileItemGrid(data.media.items));
                    return;
                  }

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

                    items.add(
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Theming.offset,
                        ),
                        sliver: TileItemGrid(
                          data.media.items.sublist(beg, end),
                        ),
                      ),
                    );
                  }
                },
              );

          final topBar = studio != null
              ? TopBar(
                  title: name,
                  trailing: [
                    TopBarIcon(
                      tooltip: 'More',
                      icon: Ionicons.ellipsis_horizontal,
                      onTap: () => showSheet(
                        context,
                        GradientSheet.link(context, studio.siteUrl),
                      ),
                    ),
                  ],
                )
              : const TopBar();

          return TabScaffold(
            topBar: topBar,
            floatingBar: FloatingBar(
              scrollCtrl: _ctrl,
              children: studio != null
                  ? [
                      _FavoriteButton(
                        studio,
                        ref
                            .read(studioProvider(widget.id).notifier)
                            .toggleFavorite,
                      ),
                      _FilterButton(widget.id),
                    ]
                  : const [],
            ),
            child: ConstrainedView(
              child: CustomScrollView(
                physics: Theming.bouncyPhysics,
                controller: hasNext != null ? _ctrl : null,
                slivers: [
                  SliverRefreshControl(
                    onRefresh: () {
                      ref.invalidate(studioProvider(widget.id));
                      ref.invalidate(studioMediaProvider(widget.id));
                    },
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
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.studio, this.toggleFavorite);

  final Studio studio;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final studio = widget.studio;

    return ActionButton(
      icon: studio.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: studio.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () async {
        setState(() => studio.isFavorite = !studio.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => studio.isFavorite = !studio.isFavorite);
        if (context.mounted) Toast.show(context, err.toString());
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

            final onDone = (_) =>
                ref.read(studioFilterProvider(id).notifier).state = filter;

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: Theming.tapTargetSize * 5,
                builder: (context, scrollCtrl) => ListView(
                  controller: scrollCtrl,
                  physics: Theming.bouncyPhysics,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Theming.offset,
                    vertical: 20,
                  ),
                  children: [
                    ChipSelector.ensureSelected(
                      title: 'Sort',
                      items: MediaSort.values.map((v) => (v.label, v)).toList(),
                      value: filter.sort,
                      onChanged: (v) => filter = filter.copyWith(sort: v),
                    ),
                    ChipSelector(
                      title: 'List Presence',
                      items: const [
                        ('In Lists', true),
                        ('Not in Lists', false),
                      ],
                      value: filter.inLists,
                      onChanged: (v) => filter = filter.copyWith(
                        inLists: () => v,
                      ),
                    ),
                    ChipSelector(
                      title: 'Main Studio',
                      items: const [('Is Main', true), ('Is Not Main', false)],
                      value: filter.isMain,
                      onChanged: (v) => filter = filter.copyWith(
                        isMain: () => v,
                      ),
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

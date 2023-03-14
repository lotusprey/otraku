import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/favorites/favorites_provider.dart';
import 'package:otraku/studio/studio_grid.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/grids/tile_item_grid.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView(this.id);

  final int id;

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> {
  FavoriteType _tab = FavoriteType.anime;
  late final _ctrl = PaginationController(
    loadMore: () => ref.read(favoritesProvider(widget.id)).fetch(),
  );

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(
      favoritesProvider(widget.id).select((s) => s.getCount(_tab)),
    );

    final refreshControl = SliverRefreshControl(
      onRefresh: () => ref.invalidate(favoritesProvider(widget.id)),
    );

    return PageScaffold(
      bottomBar: BottomBarIconTabs(
        current: _tab.index,
        onChanged: (page) {
          setState(() => _tab = FavoriteType.values.elementAt(page));
          _ctrl.scrollToTop();
        },
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Anime': Ionicons.film_outline,
          'Manga': Ionicons.bookmark_outline,
          'Characters': Ionicons.man_outline,
          'Staff': Ionicons.mic_outline,
          'Studios': Ionicons.business_outline,
        },
      ),
      child: TabScaffold(
        topBar: TopBar(
          title: _tab.text,
          trailing: [
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
          ],
        ),
        child: DirectPageView(
          current: _tab.index,
          onChanged: (page) =>
              setState(() => _tab = FavoriteType.values.elementAt(page)),
          children: [
            _AnimeTab(widget.id, _ctrl, refreshControl),
            _MangaTab(widget.id, _ctrl, refreshControl),
            _CharactersTab(widget.id, _ctrl, refreshControl),
            _StaffTab(widget.id, _ctrl, refreshControl),
            _StudiosTab(widget.id, _ctrl, refreshControl),
          ],
        ),
      ),
    );
  }
}

class _AnimeTab extends StatelessWidget {
  const _AnimeTab(this.id, this._ctrl, this.refreshControl);

  final int id;
  final PaginationController _ctrl;
  final Widget refreshControl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<FavoritesNotifier>(
          favoritesProvider(id),
          (_, s) {
            s.anime.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load anime',
                  content: error.toString(),
                ),
              ),
            );
          },
        );

        return ref.watch(favoritesProvider(id)).anime.when(
            loading: () => const Center(child: Loader()),
            error: (_, __) =>
                const Center(child: Text('Failed to load favourite anime')),
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(child: Text('No favourite anime'));
              }

              return ConstrainedView(
                child: CustomScrollView(
                  physics: Consts.physics,
                  controller: _ctrl,
                  slivers: [
                    refreshControl,
                    TileItemGrid(data.items),
                    SliverFooter(loading: data.hasNext),
                  ],
                ),
              );
            });
      },
    );
  }
}

class _MangaTab extends StatelessWidget {
  const _MangaTab(this.id, this._ctrl, this.refreshControl);

  final int id;
  final PaginationController _ctrl;
  final Widget refreshControl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<FavoritesNotifier>(
          favoritesProvider(id),
          (_, s) {
            s.manga.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load manga',
                  content: error.toString(),
                ),
              ),
            );
          },
        );

        return ref.watch(favoritesProvider(id)).manga.when(
            loading: () => const Center(child: Loader()),
            error: (_, __) =>
                const Center(child: Text('Failed to load favourite manga')),
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(child: Text('No favourite manga'));
              }

              return ConstrainedView(
                child: CustomScrollView(
                  physics: Consts.physics,
                  controller: _ctrl,
                  slivers: [
                    refreshControl,
                    TileItemGrid(data.items),
                    SliverFooter(loading: data.hasNext),
                  ],
                ),
              );
            });
      },
    );
  }
}

class _CharactersTab extends StatelessWidget {
  const _CharactersTab(this.id, this._ctrl, this.refreshControl);

  final int id;
  final PaginationController _ctrl;
  final Widget refreshControl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<FavoritesNotifier>(
          favoritesProvider(id),
          (_, s) {
            s.characters.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load characters',
                  content: error.toString(),
                ),
              ),
            );
          },
        );

        return ref.watch(favoritesProvider(id)).characters.when(
            loading: () => const Center(child: Loader()),
            error: (_, __) => const Center(
                child: Text('Failed to load favourite characters')),
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(child: Text('No favourite characters'));
              }

              return ConstrainedView(
                child: CustomScrollView(
                  physics: Consts.physics,
                  controller: _ctrl,
                  slivers: [
                    refreshControl,
                    TileItemGrid(data.items),
                    SliverFooter(loading: data.hasNext),
                  ],
                ),
              );
            });
      },
    );
  }
}

class _StaffTab extends StatelessWidget {
  const _StaffTab(this.id, this._ctrl, this.refreshControl);

  final int id;
  final PaginationController _ctrl;
  final Widget refreshControl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<FavoritesNotifier>(
          favoritesProvider(id),
          (_, s) {
            s.staff.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load staff',
                  content: error.toString(),
                ),
              ),
            );
          },
        );

        return ref.watch(favoritesProvider(id)).staff.when(
            loading: () => const Center(child: Loader()),
            error: (_, __) =>
                const Center(child: Text('Failed to load favourite staff')),
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(child: Text('No favourite staff'));
              }

              return ConstrainedView(
                child: CustomScrollView(
                  physics: Consts.physics,
                  controller: _ctrl,
                  slivers: [
                    refreshControl,
                    TileItemGrid(data.items),
                    SliverFooter(loading: data.hasNext),
                  ],
                ),
              );
            });
      },
    );
  }
}

class _StudiosTab extends StatelessWidget {
  const _StudiosTab(this.id, this._ctrl, this.refreshControl);

  final int id;
  final PaginationController _ctrl;
  final Widget refreshControl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<FavoritesNotifier>(
          favoritesProvider(id),
          (_, s) {
            s.studios.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load studios',
                  content: error.toString(),
                ),
              ),
            );
          },
        );

        return ref.watch(favoritesProvider(id)).studios.when(
            loading: () => const Center(child: Loader()),
            error: (_, __) =>
                const Center(child: Text('Failed to load favourite studios')),
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(child: Text('No favourite studios'));
              }

              return ConstrainedView(
                child: CustomScrollView(
                  physics: Consts.physics,
                  controller: _ctrl,
                  slivers: [
                    refreshControl,
                    StudioGrid(data.items),
                    SliverFooter(loading: data.hasNext),
                  ],
                ),
              );
            });
      },
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/feature/favorites/favorites_model.dart';
import 'package:otraku/feature/favorites/favorites_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/widget/sheets.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView(this.userId);

  final int userId;

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(
    length: FavoritesType.values.length,
    vsync: this,
  );
  late final _scrollCtrl = PagedController(
    loadMore: () => ref
        .read(favoritesProvider(widget.userId).notifier)
        .fetch(FavoritesType.values[_tabCtrl.index]),
  );

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = FavoritesType.values[_tabCtrl.index];

    final isViewer = ref.watch(viewerIdProvider) == widget.userId;

    final count = ref.watch(
      favoritesProvider(widget.userId).select(
        (s) => s.valueOrNull?.getCount(type) ?? 0,
      ),
    );

    final onRefresh = (invalidate) => invalidate(favoritesProvider(widget.userId));

    final toggleFavorite =
        (int itemId) => ref.read(favoritesProvider(widget.userId).notifier).toggleFavorite(itemId);

    final inEditingMode = ref.watch(
      favoritesProvider(widget.userId).select(
        (s) => s.valueOrNull?.edit != null,
      ),
    );

    return AdaptiveScaffold(
      topBar: TopBarAnimatedSwitcher(
        TopBar(
          key: inEditingMode ? const Key('EditTopBar') : Key('${type.title}TopBar'),
          title: type.title,
          trailing: [
            if (inEditingMode) ...[
              IconButton(
                tooltip: 'Cancel',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => ref.read(favoritesProvider(widget.userId).notifier).cancelEdit(),
              ),
              IconButton(
                tooltip: 'Save',
                icon: const Icon(Icons.save_outlined),
                onPressed: () =>
                    ref.read(favoritesProvider(widget.userId).notifier).saveEdit().then((err) {
                  if (err == null || !context.mounted) return;

                  SnackBarExtension.show(context, 'Failed to reorder: $err');
                }),
              ),
            ] else if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: Theming.offset),
                child: Text(
                  count.toString(),
                  style: TextTheme.of(context).titleSmall,
                ),
              ),
          ],
        ),
      ),
      floatingAction: !isViewer || inEditingMode
          ? null
          : HidingFloatingActionButton(
              key: const Key('edit'),
              scrollCtrl: _scrollCtrl,
              child: FloatingActionButton(
                tooltip: 'Edit',
                child: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    ref.read(favoritesProvider(widget.userId).notifier).startEdit(type),
              ),
            ),
      navigationConfig: inEditingMode
          ? null
          : NavigationConfig(
              selected: _tabCtrl.index,
              onChanged: (i) => _tabCtrl.index = i,
              onSame: (_) => _scrollCtrl.scrollToTop(),
              items: const {
                'Anime': Ionicons.film_outline,
                'Manga': Ionicons.book_outline,
                'Characters': Ionicons.man_outline,
                'Staff': Ionicons.briefcase_outline,
                'Studios': Ionicons.business_outline,
              },
            ),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(seconds: 0),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        child: TabBarView(
          key: inEditingMode ? const Key('editTabBarView') : const Key('tabBarView'),
          controller: _tabCtrl,
          children: [
            PagedView<FavoriteItem>(
              provider: favoritesProvider(widget.userId).select(
                (s) => s.unwrapPrevious().whenData((data) => data.anime),
              ),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) => context.push(
                      Routes.media(item.id, item.imageUrl),
                    );
                final onLongTapItem = (FavoriteItem item) => showSheet(
                      context,
                      EditView((id: item.id, setComplete: false)),
                    );

                return inEditingMode
                    ? _EditList(
                        data.items,
                        onTapItem,
                        onLongTapItem,
                        toggleFavorite,
                      )
                    : _ImageGrid(data.items, onTapItem, onLongTapItem);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(widget.userId).select(
                (s) => s.unwrapPrevious().whenData((data) => data.manga),
              ),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) => context.push(
                      Routes.media(item.id, item.imageUrl),
                    );
                final onLongTapItem = (FavoriteItem item) => showSheet(
                      context,
                      EditView((id: item.id, setComplete: false)),
                    );

                return inEditingMode
                    ? _EditList(
                        data.items,
                        onTapItem,
                        onLongTapItem,
                        toggleFavorite,
                      )
                    : _ImageGrid(data.items, onTapItem, onLongTapItem);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(widget.userId).select(
                (s) => s.unwrapPrevious().whenData((data) => data.characters),
              ),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) => context.push(
                      Routes.character(item.id, item.imageUrl),
                    );

                return inEditingMode
                    ? _EditList(data.items, onTapItem, null, toggleFavorite)
                    : _ImageGrid(data.items, onTapItem, null);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(widget.userId).select(
                (s) => s.unwrapPrevious().whenData((data) => data.staff),
              ),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) => context.push(
                      Routes.staff(item.id, item.imageUrl),
                    );

                return inEditingMode
                    ? _EditList(data.items, onTapItem, null, toggleFavorite)
                    : _ImageGrid(data.items, onTapItem, null);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(widget.userId).select(
                (s) => s.unwrapPrevious().whenData((data) => data.studios),
              ),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) => context.push(
                      Routes.studio(item.id, item.imageUrl),
                    );

                return inEditingMode
                    ? _EditList(
                        data.items,
                        onTapItem,
                        null,
                        toggleFavorite,
                        compact: true,
                      )
                    : _TextGrid(data.items, onTapItem);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatefulWidget {
  const _ImageGrid(this.items, this.onTapItem, this.onLongTapItem);

  final List<FavoriteItem> items;
  final void Function(FavoriteItem) onTapItem;
  final void Function(FavoriteItem)? onLongTapItem;

  @override
  State<_ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<_ImageGrid> {
  late List<FavoriteItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items.where((e) => e.isFavorite).toList();
  }

  @override
  void didUpdateWidget(covariant _ImageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = widget.items.where((e) => e.isFavorite).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 40,
        rawHWRatio: Theming.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: _items.length,
        (_, i) => InkWell(
          borderRadius: Theming.borderRadiusSmall,
          onTap: () => widget.onTapItem(_items[i]),
          onLongPress: () => widget.onLongTapItem?.call(_items[i]),
          child: Column(
            children: [
              if (_items[i].imageUrl != null)
                Expanded(
                  child: Hero(
                    tag: _items[i].id,
                    child: ClipRRect(
                      borderRadius: Theming.borderRadiusSmall,
                      child: CachedImage(_items[i].imageUrl!),
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              SizedBox(
                height: 35,
                child: Text(
                  _items[i].name,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: TextTheme.of(context).bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextGrid extends StatefulWidget {
  const _TextGrid(this.items, this.onTapItem);

  final List<FavoriteItem> items;
  final void Function(FavoriteItem) onTapItem;

  @override
  State<_TextGrid> createState() => _TextGridState();
}

class _TextGridState extends State<_TextGrid> {
  late List<FavoriteItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items.where((e) => e.isFavorite).toList();
  }

  @override
  void didUpdateWidget(covariant _TextGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = widget.items.where((e) => e.isFavorite).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 230,
        height: 60,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: _items.length,
        (_, i) => InkWell(
          borderRadius: Theming.borderRadiusSmall,
          onTap: () => widget.onTapItem(_items[i]),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Theming.offset,
              vertical: Theming.offset / 2,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Hero(
                tag: _items[i].id,
                child: Text(
                  _items[i].name,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: TextTheme.of(context).titleLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditList extends StatefulWidget {
  const _EditList(
    this.items,
    this.onTapItem,
    this.onLongTapItem,
    this.toggleFavorite, {
    this.compact = false,
  });

  final List<FavoriteItem> items;
  final void Function(FavoriteItem) onTapItem;
  final void Function(FavoriteItem)? onLongTapItem;
  final Future<Object?> Function(int) toggleFavorite;
  final bool compact;

  @override
  State<_EditList> createState() => _EditListState();
}

class _EditListState extends State<_EditList> {
  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemExtent: widget.compact ? 50 : 100,
      itemCount: widget.items.length,
      onReorder: (oldIndex, newIndex) => setState(() {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        final item = widget.items.removeAt(oldIndex);
        widget.items.insert(newIndex, item);
      }),
      proxyDecorator: (child, index, animation) {
        final value = (animation.value * 2).clamp(0.0, 1.0);

        return Material(
          borderRadius: Theming.borderRadiusSmall,
          elevation: lerpDouble(0, 6, value) ?? 0,
          child: child,
        );
      },
      itemBuilder: (context, i) {
        final item = widget.items[i];

        return InkWell(
          key: Key('$i'),
          borderRadius: Theming.borderRadiusSmall,
          onTap: () => widget.onTapItem(item),
          onLongPress: () => widget.onLongTapItem?.call(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                if (item.imageUrl != null) ...[
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: Theming.borderRadiusSmall,
                    child: CachedImage(
                      item.imageUrl!,
                      width: 90 / Theming.coverHtoWRatio,
                      height: 90,
                    ),
                  ),
                ],
                const SizedBox(width: Theming.offset),
                Expanded(child: Text(item.name)),
                IconButton(
                  icon: item.isFavorite
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border_rounded),
                  tooltip: item.isFavorite ? 'Unfavorite' : 'Favorite',
                  onPressed: () async {
                    final isFavorite = item.isFavorite;
                    setState(() => item.isFavorite = !isFavorite);

                    final err = await widget.toggleFavorite(item.id);
                    if (err == null) return;

                    setState(() => item.isFavorite = isFavorite);
                    if (context.mounted) {
                      SnackBarExtension.show(context, err.toString());
                    }
                  },
                ),
                ReorderableDragStartListener(
                  index: i,
                  child: Padding(
                    padding: Theming.paddingAll,
                    child: Icon(Icons.drag_handle_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

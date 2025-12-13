import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
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
  late final _tabCtrl = TabController(length: FavoritesType.values.length, vsync: this);
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

    final options = ref.watch(persistenceProvider.select((s) => s.options));

    final count = ref.watch(
      favoritesProvider(widget.userId).select((s) => s.value?.getCount(type) ?? 0),
    );

    final onRefresh = (invalidate) => invalidate(favoritesProvider(widget.userId));

    final toggleFavorite = (int itemId) =>
        ref.read(favoritesProvider(widget.userId).notifier).toggleFavorite(itemId);

    final inEditingMode = ref.watch(
      favoritesProvider(widget.userId).select((s) => s.value?.edit != null),
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
                padding: const .only(right: Theming.offset),
                child: Text(count.toString(), style: TextTheme.of(context).titleSmall),
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
          position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
          child: child,
        ),
        child: TabBarView(
          key: inEditingMode ? const Key('editTabBarView') : const Key('tabBarView'),
          controller: _tabCtrl,
          children: [
            PagedView<FavoriteItem>(
              provider: favoritesProvider(
                widget.userId,
              ).select((s) => s.unwrapPrevious().whenData((data) => data.anime)),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) =>
                    context.push(Routes.media(item.id, item.imageUrl));
                final onLongTapItem = (FavoriteItem item) =>
                    showSheet(context, EditView((id: item.id, setComplete: false)));

                return inEditingMode
                    ? _EditList(
                        data.items,
                        onTapItem,
                        onLongTapItem,
                        toggleFavorite,
                        options.highContrast,
                      )
                    : _ImageGrid(data.items, onTapItem, onLongTapItem, options.highContrast);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(
                widget.userId,
              ).select((s) => s.unwrapPrevious().whenData((data) => data.manga)),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) =>
                    context.push(Routes.media(item.id, item.imageUrl));
                final onLongTapItem = (FavoriteItem item) =>
                    showSheet(context, EditView((id: item.id, setComplete: false)));

                return inEditingMode
                    ? _EditList(
                        data.items,
                        onTapItem,
                        onLongTapItem,
                        toggleFavorite,
                        options.highContrast,
                      )
                    : _ImageGrid(data.items, onTapItem, onLongTapItem, options.highContrast);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(
                widget.userId,
              ).select((s) => s.unwrapPrevious().whenData((data) => data.characters)),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) =>
                    context.push(Routes.character(item.id, item.imageUrl));

                return inEditingMode
                    ? _EditList(data.items, onTapItem, null, toggleFavorite, options.highContrast)
                    : _ImageGrid(data.items, onTapItem, null, options.highContrast);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(
                widget.userId,
              ).select((s) => s.unwrapPrevious().whenData((data) => data.staff)),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) =>
                    context.push(Routes.staff(item.id, item.imageUrl));

                return inEditingMode
                    ? _EditList(data.items, onTapItem, null, toggleFavorite, options.highContrast)
                    : _ImageGrid(data.items, onTapItem, null, options.highContrast);
              },
            ),
            PagedView<FavoriteItem>(
              provider: favoritesProvider(
                widget.userId,
              ).select((s) => s.unwrapPrevious().whenData((data) => data.studios)),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
              onData: (data) {
                final onTapItem = (FavoriteItem item) =>
                    context.push(Routes.studio(item.id, item.imageUrl));

                return inEditingMode
                    ? _EditList(
                        data.items,
                        onTapItem,
                        null,
                        toggleFavorite,
                        options.highContrast,
                        compact: true,
                      )
                    : _TextGrid(data.items, onTapItem, options.highContrast);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatefulWidget {
  const _ImageGrid(this.items, this.onTapItem, this.onLongTapItem, this.highContrast);

  final List<FavoriteItem> items;
  final void Function(FavoriteItem) onTapItem;
  final void Function(FavoriteItem)? onLongTapItem;
  final bool highContrast;

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
    final lineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final textHeight = lineHeight * 2 + 10;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: textHeight,
        rawHWRatio: Theming.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: _items.length,
        (_, i) => InkWell(
          borderRadius: Theming.borderRadiusSmall,
          onTap: () => context.push(Routes.character(_items[i].id, _items[i].imageUrl)),
          child: CardExtension.highContrast(widget.highContrast)(
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                if (_items[i].imageUrl != null)
                  Expanded(
                    child: Hero(
                      tag: _items[i].id,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Theming.radiusSmall),
                        child: CachedImage(_items[i].imageUrl!),
                      ),
                    ),
                  ),
                SizedBox(
                  height: textHeight,
                  child: Padding(
                    padding: const .all(5),
                    child: Text(_items[i].name, maxLines: 2, overflow: .ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextGrid extends StatefulWidget {
  const _TextGrid(this.items, this.onTapItem, this.highContrast);

  final List<FavoriteItem> items;
  final void Function(FavoriteItem) onTapItem;
  final bool highContrast;

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
    final lineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 230,
        height: lineHeight + 20,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: _items.length,
        (_, i) => InkWell(
          borderRadius: Theming.borderRadiusSmall,
          onTap: () => context.push(Routes.studio(_items[i].id, _items[i].name)),
          child: CardExtension.highContrast(widget.highContrast)(
            child: Padding(
              padding: Theming.paddingAll,
              child: Hero(
                tag: _items[i].id,
                child: Text(
                  _items[i].name,
                  style: TextTheme.of(context).bodyMedium,
                  overflow: .ellipsis,
                  maxLines: 1,
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
    this.toggleFavorite,
    this.highContrast, {
    this.compact = false,
  });

  final List<FavoriteItem> items;
  final void Function(FavoriteItem) onTapItem;
  final void Function(FavoriteItem)? onLongTapItem;
  final Future<Object?> Function(int) toggleFavorite;
  final bool highContrast;
  final bool compact;

  @override
  State<_EditList> createState() => _EditListState();
}

class _EditListState extends State<_EditList> {
  @override
  Widget build(BuildContext context) {
    final lineCount = widget.compact ? 1 : 4;
    final lineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final itemExtent = max(lineHeight * lineCount, Theming.iconBig + 20) + 20;

    return SliverReorderableList(
      itemExtent: itemExtent,
      itemCount: widget.items.length,
      onReorder: (oldIndex, newIndex) => setState(() {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        final item = widget.items.removeAt(oldIndex);
        widget.items.insert(newIndex, item);
      }),
      proxyDecorator: (child, index, animation) {
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColorScheme.of(context).surface,
                blurRadius: 12,
                spreadRadius: 1,
                // offset: Offset(0, 4 * animation.value),
              ),
            ],
          ),
          child: child,
        );
      },
      itemBuilder: (context, i) {
        final item = widget.items[i];

        Widget content = Padding(
          padding: const .only(left: 10, top: 5, bottom: 5),
          child: Row(
            spacing: Theming.offset,
            children: [
              Expanded(
                child: Text(item.name, overflow: .ellipsis, maxLines: lineCount),
              ),
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
                  child: Icon(Icons.drag_handle_rounded, size: Theming.iconBig),
                ),
              ),
            ],
          ),
        );

        if (item.imageUrl != null) {
          content = Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                child: CachedImage(item.imageUrl!, width: itemExtent / Theming.coverHtoWRatio),
              ),
              Expanded(child: content),
            ],
          );
        }

        return CardExtension.highContrast(widget.highContrast)(
          key: Key('$i'),
          margin: const .only(bottom: Theming.offset),
          child: InkWell(
            borderRadius: Theming.borderRadiusSmall,
            onTap: () => widget.onTapItem(item),
            onLongPress: () => widget.onLongTapItem?.call(item),
            child: content,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/feature/character/character_item_grid.dart';
import 'package:otraku/feature/character/character_item_model.dart';
import 'package:otraku/feature/media/media_item_grid.dart';
import 'package:otraku/feature/media/media_item_model.dart';
import 'package:otraku/feature/staff/staff_item_grid.dart';
import 'package:otraku/feature/staff/staff_item_model.dart';
import 'package:otraku/feature/studio/studio_item_model.dart';
import 'package:otraku/feature/favorites/favorites_model.dart';
import 'package:otraku/feature/favorites/favorites_provider.dart';
import 'package:otraku/feature/studio/studio_item_grid.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/scroll_physics.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/paged_view.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView(this.id);

  final int id;

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(
    length: FavoritesTab.values.length,
    vsync: this,
  );
  late final _scrollCtrl = PagedController(
    loadMore: () => ref
        .read(favoritesProvider(widget.id).notifier)
        .fetch(FavoritesTab.values[_tabCtrl.index]),
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
    final tab = FavoritesTab.values[_tabCtrl.index];

    final count = ref.watch(
      favoritesProvider(widget.id).select(
        (s) => s.valueOrNull?.getCount(tab) ?? 0,
      ),
    );

    final onRefresh = (invalidate) => invalidate(favoritesProvider(widget.id));

    return AdaptiveScaffold(
      (context, compact) => ScaffoldConfig(
        topBar: TopBarAnimatedSwitcher(
          TopBar(
            key: Key('${tab.title}TopBar'),
            title: tab.title,
            trailing: [
              if (count > 0)
                Padding(
                  padding: const EdgeInsets.only(right: Theming.offset),
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
            ],
          ),
        ),
        navigationConfig: NavigationConfig(
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
        child: TabBarView(
          controller: _tabCtrl,
          physics: const FastTabBarViewScrollPhysics(),
          children: [
            PagedView<MediaItem>(
              provider: favoritesProvider(widget.id).select(
                (s) => s.unwrapPrevious().whenData((data) => data.anime),
              ),
              onData: (data) => MediaItemGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
            PagedView<MediaItem>(
              provider: favoritesProvider(widget.id).select(
                (s) => s.unwrapPrevious().whenData((data) => data.manga),
              ),
              onData: (data) => MediaItemGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
            PagedView<CharacterItem>(
              provider: favoritesProvider(widget.id).select(
                (s) => s.unwrapPrevious().whenData((data) => data.characters),
              ),
              onData: (data) => CharacterItemGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
            PagedView<StaffItem>(
              provider: favoritesProvider(widget.id).select(
                (s) => s.unwrapPrevious().whenData((data) => data.staff),
              ),
              onData: (data) => StaffItemGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
            PagedView<StudioItem>(
              provider: favoritesProvider(widget.id).select(
                (s) => s.unwrapPrevious().whenData((data) => data.studios),
              ),
              onData: (data) => StudioItemGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

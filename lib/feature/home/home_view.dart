import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activities_view.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/collection/collection_floating_action.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/collection/collection_top_bar.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_floating_action.dart';
import 'package:otraku/feature/discover/discover_provider.dart';
import 'package:otraku/feature/discover/discover_top_bar.dart';
import 'package:otraku/feature/feed/feed_floating_action.dart';
import 'package:otraku/feature/feed/feed_top_bar.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/tag/tag_provider.dart';
import 'package:otraku/feature/user/user_providers.dart';
import 'package:otraku/feature/user/user_view.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/discover/discover_view.dart';
import 'package:otraku/feature/collection/collection_view.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/scroll_physics.dart';
import 'package:otraku/widget/layout/top_bar.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key, this.tab});

  final HomeTab? tab;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  final _searchFocusNode = FocusNode();
  final _animeScrollCtrl = ScrollController();
  final _mangaScrollCtrl = ScrollController();
  late final _feedScrollCtrl = PagedController(
    loadMore: () => ref.read(activitiesProvider(null).notifier).fetch(),
  );
  late final _discoverScrollCtrl = PagedController(
    loadMore: () => ref.read(discoverProvider.notifier).fetch(),
  );
  late final _tabCtrl = TabController(
    length: HomeTab.values.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    final persistence = ref.read(persistenceProvider);

    _tabCtrl.index = persistence.options.homeTab.index;
    if (widget.tab != null) _tabCtrl.index = widget.tab!.index;

    _tabCtrl.addListener(
      () => WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _searchFocusNode.unfocus();
          context.go(Routes.home(HomeTab.values[_tabCtrl.index]));
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab != null) _tabCtrl.index = widget.tab!.index;
  }

  @override
  void deactivate() {
    ref.invalidate(discoverProvider);
    ref.invalidate(discoverFilterProvider);
    ref.invalidate(activitiesProvider(null));
    super.deactivate();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _animeScrollCtrl.dispose();
    _mangaScrollCtrl.dispose();
    _feedScrollCtrl.dispose();
    _discoverScrollCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider.select((_) => null));
    ref.watch(tagsProvider.select((_) => null));

    if (_tabCtrl.index == HomeTab.feed.index) {
      ref.watch(activitiesProvider(null).select((_) => null));
    } else if (_tabCtrl.index == HomeTab.discover.index) {
      ref.watch(discoverProvider.select((_) => null));
    }

    UserTag? userTag;
    CollectionTag? animeCollectionTag;
    CollectionTag? mangaCollectionTag;

    final viewerId = ref.watch(viewerIdProvider);
    if (viewerId != null) {
      userTag = idUserTag(viewerId);
      animeCollectionTag = (userId: viewerId, ofAnime: true);
      mangaCollectionTag = (userId: viewerId, ofAnime: false);

      ref.watch(userProvider(userTag).select((_) => null));
      ref.watch(
        collectionEntriesProvider(animeCollectionTag).select((_) => null),
      );
      ref.watch(
        collectionEntriesProvider(mangaCollectionTag).select((_) => null),
      );
    }

    final primaryScrollCtrl = PrimaryScrollController.of(context);
    final home = ref.watch(homeProvider);

    final topBar = TopBarAnimatedSwitcher(
      switch (_tabCtrl.index) {
        0 => const TopBar(
            key: Key('feedTopBar'),
            title: 'Feed',
            trailing: [
              FeedTopBarTrailingContent(),
            ],
          ),
        1 when animeCollectionTag != null => TopBar(
            key: const Key('animeCollectionTopBar'),
            trailing: [
              CollectionTopBarTrailingContent(
                animeCollectionTag,
                _searchFocusNode,
              ),
            ],
          ),
        2 when mangaCollectionTag != null => TopBar(
            key: const Key('mangaCollectionTopBar'),
            trailing: [
              CollectionTopBarTrailingContent(
                mangaCollectionTag,
                _searchFocusNode,
              ),
            ],
          ),
        3 => TopBar(
            key: const Key('discoverTobBar'),
            trailing: [
              DiscoverTopBarTrailingContent(_searchFocusNode),
            ],
          ),
        _ => const EmptyTopBar() as PreferredSizeWidget,
      },
    );

    final navigationConfig = NavigationConfig(
      items: _homeTabs,
      selected: _tabCtrl.index,
      onChanged: (i) => context.go(Routes.home(HomeTab.values[i])),
      onSame: (i) {
        final tab = HomeTab.values[i];

        switch (tab) {
          case HomeTab.feed:
            _feedScrollCtrl.scrollToTop();
          case HomeTab.anime:
            if (_animeScrollCtrl.position.pixels > 0) {
              _animeScrollCtrl.scrollToTop();
              return;
            }

            _toggleSearchFocus();
          case HomeTab.manga:
            if (_mangaScrollCtrl.position.pixels > 0) {
              _mangaScrollCtrl.scrollToTop();
              return;
            }

            _toggleSearchFocus();
          case HomeTab.discover:
            if (_discoverScrollCtrl.position.pixels > 0) {
              _discoverScrollCtrl.scrollToTop();
              return;
            }

            _toggleSearchFocus();
            return;
          case HomeTab.profile:
            if (primaryScrollCtrl.positions.last.pixels > 0) {
              primaryScrollCtrl.scrollToTop();
              return;
            }

            context.push(Routes.settings);
        }
      },
    );

    return AdaptiveScaffold(
      (context, compact) {
        final floatingAction = switch (_tabCtrl.index) {
          0 => HidingFloatingActionButton(
              key: const Key('feed'),
              scrollCtrl: _feedScrollCtrl,
              child: FeedFloatingAction(ref),
            ),
          1 => (compact || !home.didExpandAnimeCollection) &&
                  animeCollectionTag != null
              ? HidingFloatingActionButton(
                  key: const Key('anime'),
                  scrollCtrl: _animeScrollCtrl,
                  child: CollectionFloatingAction(animeCollectionTag),
                )
              : null,
          2 => (compact || !home.didExpandMangaCollection) &&
                  mangaCollectionTag != null
              ? HidingFloatingActionButton(
                  key: const Key('manga'),
                  scrollCtrl: _mangaScrollCtrl,
                  child: CollectionFloatingAction(mangaCollectionTag),
                )
              : null,
          3 => compact
              ? HidingFloatingActionButton(
                  key: const Key('discover'),
                  scrollCtrl: _discoverScrollCtrl,
                  child: const DiscoverFloatingAction(),
                )
              : null,
          _ => null,
        };

        final child = TabBarView(
          controller: _tabCtrl,
          physics: const FastTabBarViewScrollPhysics(),
          children: [
            ActivitiesSubView(null, _feedScrollCtrl),
            CollectionSubview(
              scrollCtrl: _animeScrollCtrl,
              tag: animeCollectionTag,
              compact: compact,
              key: Key(true.toString()),
            ),
            CollectionSubview(
              scrollCtrl: _mangaScrollCtrl,
              tag: mangaCollectionTag,
              compact: compact,
              key: Key(false.toString()),
            ),
            DiscoverSubview(_discoverScrollCtrl, compact),
            UserHomeView(
              userTag,
              null,
              homeScrollCtrl: primaryScrollCtrl,
              removableTopPadding: topBar.preferredSize.height,
            ),
          ],
        );

        return switch (compact) {
          true => ScaffoldConfig(
              topBar: topBar,
              floatingAction: floatingAction,
              navigationConfig: navigationConfig,
              child: child,
            ),
          false => ScaffoldConfig(
              topBar: topBar,
              floatingAction: floatingAction,
              navigationConfig: navigationConfig,
              child: child,
            ),
        };
      },
    );
  }

  static final _homeTabs = {
    HomeTab.feed.label: Ionicons.file_tray_outline,
    HomeTab.anime.label: Ionicons.film_outline,
    HomeTab.manga.label: Ionicons.book_outline,
    HomeTab.discover.label: Ionicons.compass_outline,
    HomeTab.profile.label: Ionicons.person_outline,
  };

  void _toggleSearchFocus() => _searchFocusNode.hasFocus
      ? _searchFocusNode.unfocus()
      : _searchFocusNode.requestFocus();
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/collection/collection_entries_provider.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_provider.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/tag/tag_provider.dart';
import 'package:otraku/feature/user/user_providers.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/feature/discover/discover_view.dart';
import 'package:otraku/feature/collection/collection_view.dart';
import 'package:otraku/feature/feed/feed_view.dart';
import 'package:otraku/feature/user/user_view.dart';
import 'package:otraku/widget/layouts/bottom_bar.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({this.tab});

  final HomeTab? tab;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  final _id = Persistence().id!;
  late final _userTag = idUserTag(_id);
  late final _animeCollectionTag = (userId: _id, ofAnime: true);
  late final _mangaCollectionTag = (userId: _id, ofAnime: false);

  final _searchFocusNode = FocusNode();
  final _animeScrollCtrl = ScrollController();
  final _mangaScrollCtrl = ScrollController();
  late final _feedScrollCtrl = PagedController(
    loadMore: () => ref.read(activitiesProvider(homeFeedId).notifier).fetch(),
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
    _tabCtrl.index = Persistence().defaultHomeTab.index;
    if (widget.tab != null) _tabCtrl.index = widget.tab!.index;
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    if (widget.tab != null) _tabCtrl.index = widget.tab!.index;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    ref.invalidate(discoverProvider);
    ref.invalidate(discoverFilterProvider);
    ref.invalidate(activitiesProvider(homeFeedId));
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
    ref.watch(userProvider(_userTag).select((_) => null));

    if (_tabCtrl.index == HomeTab.feed.index) {
      ref.watch(activitiesProvider(homeFeedId).select((_) => null));
    } else if (_tabCtrl.index == HomeTab.discover.index) {
      ref.watch(discoverProvider.select((_) => null));
    }

    ref.watch(
        collectionEntriesProvider(_animeCollectionTag).select((_) => null));
    ref.watch(
        collectionEntriesProvider(_mangaCollectionTag).select((_) => null));

    final primaryScrollCtrl = PrimaryScrollController.of(context);

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        items: {
          for (final tab in HomeTab.values) tab.label: _homeTabIconData(tab),
        },
        onSame: (i) {
          final tab = HomeTab.values[i];

          switch (tab) {
            case HomeTab.anime:
              if (_animeScrollCtrl.position.pixels > 0) {
                _animeScrollCtrl.scrollToTop();
              } else {
                _toggleSearchFocus();
              }
              return;
            case HomeTab.manga:
              if (_mangaScrollCtrl.position.pixels > 0) {
                _mangaScrollCtrl.scrollToTop();
              } else {
                _toggleSearchFocus();
              }
              return;
            case HomeTab.discover:
              if (_discoverScrollCtrl.position.pixels > 0) {
                _discoverScrollCtrl.scrollToTop();
              } else {
                _toggleSearchFocus();
              }
              return;
            case HomeTab.feed:
              _feedScrollCtrl.scrollToTop();
            case HomeTab.profile:
              primaryScrollCtrl.scrollToTop();
              return;
          }
        },
      ),
      child: TabBarView(
        controller: _tabCtrl,
        children: [
          FeedSubview(_feedScrollCtrl),
          CollectionSubview(
            scrollCtrl: _animeScrollCtrl,
            tag: _animeCollectionTag,
            focusNode: _searchFocusNode,
            key: Key(true.toString()),
          ),
          CollectionSubview(
            scrollCtrl: _mangaScrollCtrl,
            tag: _mangaCollectionTag,
            focusNode: _searchFocusNode,
            key: Key(false.toString()),
          ),
          DiscoverSubview(_searchFocusNode, _discoverScrollCtrl),
          UserSubview(_userTag, null, primaryScrollCtrl),
        ],
      ),
    );
  }

  void _toggleSearchFocus() => _searchFocusNode.hasFocus
      ? _searchFocusNode.unfocus()
      : _searchFocusNode.requestFocus();

  IconData _homeTabIconData(HomeTab tab) => switch (tab) {
        HomeTab.feed => Ionicons.file_tray_outline,
        HomeTab.anime => Ionicons.film_outline,
        HomeTab.manga => Ionicons.book_outline,
        HomeTab.discover => Ionicons.compass_outline,
        HomeTab.profile => Ionicons.person_outline,
      };
}

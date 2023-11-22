import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/activity/activities_providers.dart';
import 'package:otraku/modules/collection/collection_preview_provider.dart';
import 'package:otraku/modules/collection/collection_preview_view.dart';
import 'package:otraku/modules/collection/collection_providers.dart';
import 'package:otraku/modules/discover/discover_providers.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/modules/tag/tag_provider.dart';
import 'package:otraku/modules/user/user_providers.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/discover/discover_view.dart';
import 'package:otraku/modules/collection/collection_view.dart';
import 'package:otraku/modules/feed/feed_view.dart';
import 'package:otraku/modules/user/user_view.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({this.tab});

  final HomeTab? tab;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  final _id = Options().id!;
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
    _tabCtrl.index = Options().defaultHomeTab.index;
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
    ref.watch(userProvider(_id).select((_) => null));

    if (_tabCtrl.index == HomeTab.feed.index) {
      ref.watch(activitiesProvider(homeFeedId).select((_) => null));
    } else if (_tabCtrl.index == HomeTab.discover.index) {
      ref.watch(discoverProvider.select((_) => null));
    }

    final notifier = ref.watch(homeProvider);

    notifier.didExpandCollection(true)
        ? ref.watch(entriesProvider(_animeCollectionTag).select((_) => null))
        : ref.watch(
            collectionPreviewProvider(_animeCollectionTag).select((_) => null),
          );

    notifier.didExpandCollection(false)
        ? ref.watch(entriesProvider(_mangaCollectionTag).select((_) => null))
        : ref.watch(
            collectionPreviewProvider(_mangaCollectionTag).select((_) => null),
          );

    final primaryScrollCtrl = PrimaryScrollController.of(context);

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        items: {
          for (final t in HomeTab.values) t.title: t.iconData,
        },
        onSame: (i) {
          final tab = HomeTab.values[i];

          switch (tab) {
            case HomeTab.anime:
              if (_animeScrollCtrl.position.pixels > 0) {
                _animeScrollCtrl.scrollToTop();
              } else if (ref.read(homeProvider).didExpandCollection(true)) {
                _toggleSearchFocus();
              }
              return;
            case HomeTab.manga:
              if (_mangaScrollCtrl.position.pixels > 0) {
                _mangaScrollCtrl.scrollToTop();
              } else if (ref.read(homeProvider).didExpandCollection(false)) {
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
          FeedView(_feedScrollCtrl),
          if (notifier.didExpandCollection(true))
            CollectionSubView(
              scrollCtrl: _animeScrollCtrl,
              tag: _animeCollectionTag,
              focusNode: _searchFocusNode,
              key: Key(true.toString()),
            )
          else
            CollectionPreviewView(
              scrollCtrl: _animeScrollCtrl,
              tag: _animeCollectionTag,
              key: Key(true.toString()),
            ),
          if (notifier.didExpandCollection(false))
            CollectionSubView(
              scrollCtrl: _mangaScrollCtrl,
              tag: _mangaCollectionTag,
              focusNode: _searchFocusNode,
              key: Key(false.toString()),
            )
          else
            CollectionPreviewView(
              scrollCtrl: _mangaScrollCtrl,
              tag: _mangaCollectionTag,
              key: Key(false.toString()),
            ),
          DiscoverView(_searchFocusNode, _discoverScrollCtrl),
          UserSubView(_id, null, primaryScrollCtrl),
        ],
      ),
    );
  }

  void _toggleSearchFocus() => _searchFocusNode.hasFocus
      ? _searchFocusNode.unfocus()
      : _searchFocusNode.requestFocus();
}

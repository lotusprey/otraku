import 'package:flutter/material.dart';
import 'package:otraku/pages/tabs/explore_tab.dart';
import 'package:otraku/pages/tabs/collections_tab.dart';
import 'package:otraku/pages/tabs/inbox_tab.dart';
import 'package:otraku/pages/tabs/profile_tab.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/navigation/floating_navigation.dart';
import 'package:otraku/tools/navigation/custom_tab_bar.dart';
import 'package:provider/provider.dart';

class TabManager extends StatefulWidget {
  //Tab indexes
  static const int INBOX = 0;
  static const int ANIME_LIST = 1;
  static const int MANGA_LIST = 2;
  static const int EXPLORE = 3;
  static const int PROFILE = 4;

  const TabManager();

  @override
  _TabManagerState createState() => _TabManagerState();
}

class _TabManagerState extends State<TabManager>
    with SingleTickerProviderStateMixin {
  FloatingNavigation _navigation;
  Map<int, Widget> _pages;
  ScrollController _scrollCtrl;
  Palette _palette;

  bool _didChangeDependencies = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      floatingActionButton: _navigation,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: const DisableAnimationAnimator(),
      body: Consumer<ViewConfig>(
        builder: (_, viewConfig, __) => SafeArea(
          child: _pages[viewConfig.pageIndex],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;

    if (!_didChangeDependencies) {
      _scrollCtrl = ScrollController();
      Provider.of<ViewConfig>(context, listen: false).init(context);

      _navigation = FloatingNavigation(
        child: CustomTabBar(),
        scrollCtrl: _scrollCtrl,
      );

      _pages = {
        TabManager.INBOX: InboxTab(),
        TabManager.ANIME_LIST: CollectionsTab(
          collection: Provider.of<AnimeCollection>(context, listen: false),
          scrollCtrl: _scrollCtrl,
          key: UniqueKey(),
        ),
        TabManager.MANGA_LIST: CollectionsTab(
          collection: Provider.of<MangaCollection>(context, listen: false),
          scrollCtrl: _scrollCtrl,
          key: UniqueKey(),
        ),
        TabManager.EXPLORE: ExploreTab(_scrollCtrl),
        TabManager.PROFILE: ProfileTab(),
      };

      _didChangeDependencies = true;
    }
  }

  @override
  void dispose() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.dispose();
    }
    super.dispose();
  }
}

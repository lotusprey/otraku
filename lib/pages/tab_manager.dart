import 'package:flutter/material.dart';
import 'package:otraku/pages/tabs/explore_tab.dart';
import 'package:otraku/pages/tabs/collections_tab.dart';
import 'package:otraku/pages/tabs/inbox_tab.dart';
import 'package:otraku/pages/tabs/profile_tab.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:provider/provider.dart';

class TabManager extends StatefulWidget {
  static const int INBOX = 0;
  static const int ANIME_LIST = 1;
  static const int MANGA_LIST = 2;
  static const int EXPLORE = 3;
  static const int PROFILE = 4;

  const TabManager();

  @override
  _TabManagerState createState() => _TabManagerState();
}

class _TabManagerState extends State<TabManager> {
  static const _box = SizedBox();

  List<Widget> _tabs;
  PageController _pageController;
  int _pageIndex;
  ScrollController _scrollCtrl;
  Palette _palette;

  bool _didChangeDependencies = false;
  bool _jumpingPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _palette.foreground,
        selectedItemColor: _palette.accent,
        unselectedItemColor: _palette.faded,
        iconSize: Palette.ICON_MEDIUM,
        type: BottomNavigationBarType.fixed,
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            title: _box,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            title: _box,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            title: _box,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            title: _box,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: _box,
          ),
        ],
        onTap: (index) {
          if (_pageIndex == index) return;

          if (index - _pageIndex > 1) {
            _jumpingPage = true;
            _pageController.jumpToPage(index - 1);
            _jumpingPage = false;
          } else if (_pageIndex - index > 1) {
            _jumpingPage = true;
            _pageController.jumpToPage(index + 1);
            _jumpingPage = false;
          }

          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        },
      ),
      body: SafeArea(
        child: PageView(
          children: _tabs,
          controller: _pageController,
          onPageChanged: (index) {
            if (!_jumpingPage) setState(() => _pageIndex = index);
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;

    if (!_didChangeDependencies) {
      Provider.of<ViewConfig>(context, listen: false).init(context);
      _scrollCtrl = ScrollController();

      _pageIndex = Provider.of<ViewConfig>(context, listen: false).pageIndex;
      _pageController = PageController(initialPage: _pageIndex);

      _tabs = [
        InboxTab(),
        CollectionsTab(
          collection: Provider.of<AnimeCollection>(context, listen: false),
          scrollCtrl: _scrollCtrl,
          key: UniqueKey(),
        ),
        CollectionsTab(
          collection: Provider.of<MangaCollection>(context, listen: false),
          scrollCtrl: _scrollCtrl,
          key: UniqueKey(),
        ),
        ExploreTab(_scrollCtrl),
        ProfileTab(),
      ];

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

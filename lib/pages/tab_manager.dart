import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/pages/tabs/explore_tab.dart';
import 'package:otraku/pages/tabs/collections_tab.dart';
import 'package:otraku/pages/tabs/inbox_tab.dart';
import 'package:otraku/pages/tabs/profile_tab.dart';
import 'package:otraku/providers/view_config.dart';

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
  List<BottomNavigationBarItem> _tabItems;
  PageController _pageCtrl;
  int _pageIndex;
  ScrollController _scrollCtrl;
  ValueNotifier<bool> _navBarVisibility;

  bool _jumpingPage = false;

  void _scrollDirection() {
    if (_scrollCtrl.position.userScrollDirection == ScrollDirection.reverse) {
      if (_navBarVisibility.value) _navBarVisibility.value = false;
    } else if (_scrollCtrl.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_navBarVisibility.value) _navBarVisibility.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _navBarVisibility,
        builder: (_, value, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: value ? 56 : 0,
          child: child,
        ),
        child: Wrap(
          children: [
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _pageIndex,
              items: _tabItems,
              onTap: (index) {
                if (_pageIndex == index) return;

                if (index - _pageIndex > 1) {
                  _jumpingPage = true;
                  _pageCtrl.jumpToPage(index - 1);
                  _jumpingPage = false;
                } else if (_pageIndex - index > 1) {
                  _jumpingPage = true;
                  _pageCtrl.jumpToPage(index + 1);
                  _jumpingPage = false;
                }

                _pageCtrl.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: PageView(
          children: _tabs,
          controller: _pageCtrl,
          onPageChanged: (index) {
            if (!_jumpingPage) setState(() => _pageIndex = index);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageIndex = ViewConfig.initialPage;
    _pageCtrl = PageController(initialPage: _pageIndex);

    _navBarVisibility = ValueNotifier(true);
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(_scrollDirection);

    _tabs = [
      InboxTab(),
      CollectionsTab(
        isAnime: true,
        scrollCtrl: _scrollCtrl,
        key: UniqueKey(),
      ),
      CollectionsTab(
        isAnime: false,
        scrollCtrl: _scrollCtrl,
        key: UniqueKey(),
      ),
      ExploreTab(_scrollCtrl),
      ProfileTab(),
    ];

    _tabItems = const [
      const BottomNavigationBarItem(
        icon: Icon(Icons.inbox),
        title: _box,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.play_arrow),
        title: _box,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bookmark),
        title: _box,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.explore),
        title: _box,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        title: _box,
      ),
    ];
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.removeListener(_scrollDirection);
      _scrollCtrl.dispose();
    }
    super.dispose();
  }
}

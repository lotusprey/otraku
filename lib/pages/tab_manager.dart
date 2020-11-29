import 'dart:ui';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/pages/tabs/explore_tab.dart';
import 'package:otraku/pages/tabs/collections_tab.dart';
import 'package:otraku/pages/tabs/inbox_tab.dart';
import 'package:otraku/pages/tabs/user_tab.dart';
import 'package:otraku/controllers/config.dart';

class TabManager extends StatelessWidget {
  static const int INBOX = 0;
  static const int ANIME_LIST = 1;
  static const int MANGA_LIST = 2;
  static const int EXPLORE = 3;
  static const int PROFILE = 4;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const InboxTab(),
      CollectionsTab(
        ofAnime: true,
        otherUserId: null,
        key: UniqueKey(),
      ),
      CollectionsTab(
        ofAnime: false,
        otherUserId: null,
        key: UniqueKey(),
      ),
      const ExploreTab(),
      const UserTab(null),
    ];

    const drawers = const [
      const SizedBox(),
      const CollectionDrawer(),
      const CollectionDrawer(),
      const SizedBox(),
      const SizedBox(),
    ];

    const navItems = const [
      const BottomNavigationBarItem(
        icon: Icon(FluentSystemIcons.ic_fluent_mail_inbox_filled),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(FluentSystemIcons.ic_fluent_movies_and_tv_filled),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(FluentSystemIcons.ic_fluent_bookmark_filled),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.explore),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(FluentSystemIcons.ic_fluent_person_filled),
        label: '',
      ),
    ];

    return Obx(
      () => Scaffold(
        extendBody: true,
        drawerScrimColor: Theme.of(context).primaryColor.withAlpha(150),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 0,
              currentIndex: Config.pageIndex,
              items: navItems,
              onTap: (index) => Config.pageIndex = index,
            ),
          ),
        ),
        drawer: drawers[Config.pageIndex],
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: tabs[Config.pageIndex],
          ),
        ),
      ),
    );
  }
}

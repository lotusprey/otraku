import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/pages/tabs/explore_tab.dart';
import 'package:otraku/pages/tabs/collections_tab.dart';
import 'package:otraku/pages/tabs/inbox_tab.dart';
import 'package:otraku/pages/tabs/user_tab.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/custom_drawer.dart';
import 'package:otraku/tools/navigators/custom_nav_bar.dart';

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
      const UserTab(null, null),
    ];

    const drawers = const [
      const SizedBox(),
      const CollectionDrawer(),
      const CollectionDrawer(),
      const ExploreDrawer(),
      const SizedBox(),
    ];

    return Obx(
      () => Scaffold(
        extendBody: true,
        drawerScrimColor: Theme.of(context).primaryColor.withAlpha(150),
        bottomNavigationBar: CustomNavBar(
          icons: const [
            FluentSystemIcons.ic_fluent_mail_inbox_regular,
            FluentSystemIcons.ic_fluent_movies_and_tv_regular,
            FluentSystemIcons.ic_fluent_bookmark_regular,
            Icons.explore_outlined,
            FluentSystemIcons.ic_fluent_person_regular,
          ],
          onChanged: (page) => Config.pageIndex = page,
          initial: Config.pageIndex,
          getIndex: () => Config.pageIndex,
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

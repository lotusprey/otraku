import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/pages/home/explore_tab.dart';
import 'package:otraku/pages/home/collection_tab.dart';
import 'package:otraku/pages/home/inbox_tab.dart';
import 'package:otraku/pages/home/user_tab.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/navigation/custom_drawer.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';

class HomePage extends StatelessWidget {
  static const int INBOX = 0;
  static const int ANIME_LIST = 1;
  static const int MANGA_LIST = 2;
  static const int EXPLORE = 3;
  static const int PROFILE = 4;

  @override
  Widget build(BuildContext context) {
    Get.put(Collection(null, true), tag: Collection.ANIME).fetch();
    Get.put(Collection(null, false), tag: Collection.MANGA).fetch();
    Get.put(User(), tag: Network.viewerId.toString()).fetchUser(null);
    Get.put(Explorer()).fetchInitial();
    Get.put(Viewer()).fetchData();

    final tabs = [
      const InboxTab(),
      CollectionTab(
        ofAnime: true,
        otherUserId: null,
        collectionTag: Collection.ANIME,
        key: UniqueKey(),
      ),
      CollectionTab(
        ofAnime: false,
        otherUserId: null,
        collectionTag: Collection.MANGA,
        key: UniqueKey(),
      ),
      const ExploreTab(),
      const UserTab(null, null),
    ];

    const drawers = const [
      const SizedBox(),
      const CollectionDrawer(Collection.ANIME),
      const CollectionDrawer(Collection.MANGA),
      const ExploreDrawer(),
      const SizedBox(),
    ];

    return GetBuilder<Config>(
      builder: (config) => Scaffold(
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
          onChanged: (page) => config.pageIndex = page,
          initial: config.pageIndex,
          getIndex: () => config.pageIndex,
        ),
        drawer: drawers[config.pageIndex],
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: tabs[config.pageIndex],
            ),
          ),
        ),
      ),
    );
  }
}

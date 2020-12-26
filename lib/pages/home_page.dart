import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/pages/home_pages/explore_page.dart';
import 'package:otraku/pages/home_pages/collection_page.dart';
import 'package:otraku/pages/home_pages/inbox_page.dart';
import 'package:otraku/pages/home_pages/user_page.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/tools/custom_drawer.dart';
import 'package:otraku/tools/navigators/custom_nav_bar.dart';

class HomePage extends StatelessWidget {
  static const int INBOX = 0;
  static const int ANIME_LIST = 1;
  static const int MANGA_LIST = 2;
  static const int EXPLORE = 3;
  static const int PROFILE = 4;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const InboxPage(),
      CollectionPage(
        ofAnime: true,
        otherUserId: null,
        collectionTag: Collection.ANIME,
        key: UniqueKey(),
      ),
      CollectionPage(
        ofAnime: false,
        otherUserId: null,
        collectionTag: Collection.MANGA,
        key: UniqueKey(),
      ),
      const ExplorePage(),
      const UserPage(null, null),
    ];

    const drawers = const [
      const SizedBox(),
      const CollectionDrawer(Collection.ANIME),
      const CollectionDrawer(Collection.MANGA),
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

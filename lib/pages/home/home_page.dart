import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/pages/home/explore_tab.dart';
import 'package:otraku/pages/home/collection_tab.dart';
import 'package:otraku/pages/home/feed_tab.dart';
import 'package:otraku/pages/home/user_tab.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/navigation/custom_drawer.dart';
import 'package:otraku/tools/navigation/nav_bar.dart';

class HomePage extends StatelessWidget {
  static const ROUTE = '/home';

  static const FEED = 0;
  static const ANIME_LIST = 1;
  static const MANGA_LIST = 2;
  static const EXPLORE = 3;
  static const PROFILE = 4;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const FeedTab(),
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
        bottomNavigationBar: NavBar(
          options: {
            FluentSystemIcons.ic_fluent_mail_inbox_regular: 'Feed',
            FluentSystemIcons.ic_fluent_movies_and_tv_regular: 'Anime',
            FluentSystemIcons.ic_fluent_bookmark_regular: 'Manga',
            Icons.explore_outlined: 'Explore',
            FluentSystemIcons.ic_fluent_person_regular: 'Profile',
          },
          onChanged: (page) => config.pageIndex = page,
          initial: config.pageIndex,
        ),
        drawer: drawers[config.pageIndex],
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: Config.TAB_SWITCH_DURATION,
            child: tabs[config.pageIndex],
          ),
        ),
      ),
    );
  }
}

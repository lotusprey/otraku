import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/pages/home/explore_page.dart';
import 'package:otraku/pages/home/collection_page.dart';
import 'package:otraku/pages/home/feed_page.dart';
import 'package:otraku/pages/home/user_page.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/custom_drawer.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

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
      const FeedPage(),
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
      const ExplorePage(),
      const UserTab(null, null),
    ];

    const drawers = [
      const SizedBox(),
      const CollectionDrawer(Collection.ANIME),
      const CollectionDrawer(Collection.MANGA),
      const ExploreDrawer(),
      const SizedBox(),
    ];

    return ValueListenableBuilder<int>(
      valueListenable: Config.index,
      builder: (_, index, __) => Scaffold(
        extendBody: true,
        drawerScrimColor: Theme.of(context).primaryColor.withAlpha(150),
        bottomNavigationBar: NavBar(
          options: {
            FluentIcons.mail_inbox_24_regular: 'Feed',
            FluentIcons.movies_and_tv_24_regular: 'Anime',
            FluentIcons.bookmark_24_regular: 'Manga',
            Icons.explore_outlined: 'Explore',
            FluentIcons.person_24_regular: 'Profile',
          },
          onChanged: (page) => Config.setIndex(page),
          initial: index,
        ),
        drawer: drawers[index],
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: Config.TAB_SWITCH_DURATION,
            child: tabs[index],
          ),
        ),
      ),
    );
  }
}

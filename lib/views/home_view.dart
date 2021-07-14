import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/views/explore_view.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/views/user_view.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/custom_drawer.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class HomeView extends StatelessWidget {
  static const FEED = 0;
  static const ANIME_LIST = 1;
  static const MANGA_LIST = 2;
  static const EXPLORE = 3;
  static const PROFILE = 4;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeFeedView(),
      HomeCollectionView(
        ofAnime: true,
        id: Client.viewerId!,
        collectionTag: CollectionController.ANIME,
        key: UniqueKey(),
      ),
      HomeCollectionView(
        ofAnime: false,
        id: Client.viewerId!,
        collectionTag: CollectionController.MANGA,
        key: UniqueKey(),
      ),
      const ExploreView(),
      HomeUserView(Client.viewerId!, null),
    ];

    const drawers = [
      null,
      const CollectionDrawer(CollectionController.ANIME),
      const CollectionDrawer(CollectionController.MANGA),
      const ExploreDrawer(),
      null,
    ];

    BackgroundHandler.checkLaunchedByNotification(context);

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: ValueListenableBuilder<int>(
        valueListenable: Config.homeIndex,
        builder: (_, index, __) => Scaffold(
          extendBody: true,
          drawerScrimColor: Theme.of(context).primaryColor.withAlpha(150),
          bottomNavigationBar: NavBar(
            options: {
              'Feed': Ionicons.file_tray_outline,
              'Anime': Ionicons.film_outline,
              'Manga': Ionicons.bookmark_outline,
              'Explore': Ionicons.compass_outline,
              'Profile': Ionicons.person_outline,
            },
            onChanged: (page) => Config.setHomeIndex(page),
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
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext ctx) async {
    bool ok = false;

    await showPopUp(
      ctx,
      ConfirmationDialog(
        title: 'Exit?',
        mainAction: 'Yes',
        secondaryAction: 'Never',
        onConfirm: () => ok = true,
      ),
    );

    return ok;
  }
}

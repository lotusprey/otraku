import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explorer_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/views/explore_view.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/views/user_view.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/bottom_drawer.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

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

    BackgroundHandler.checkLaunchedByNotification();

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: ValueListenableBuilder<int>(
        valueListenable: Config.homeIndex,
        builder: (_, index, __) => Scaffold(
          extendBody: true,
          floatingActionButton: _actionButton(context),
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

  Widget? _actionButton(BuildContext ctx) {
    final index = Config.homeIndex.value;

    if (index == ANIME_LIST || index == MANGA_LIST)
      return CollectionActionButton(
        index == ANIME_LIST
            ? CollectionController.ANIME
            : CollectionController.MANGA,
      );

    if (index == EXPLORE) {
      final ctrl = Get.find<ExplorerController>();
      return Obx(
        () => ActionButton(
          tooltip: 'Types',
          icon: ctrl.type.icon,
          scrollCtrl: ctrl.scrollCtrl,
          onTap: () => Sheet.show(
            ctx: ctx,
            sheet: ExploreBottomDrawer(ctx),
            isScrollControlled: true,
            barrierColour: Theme.of(ctx).primaryColor.withAlpha(150),
          ),
        ),
      );
    }

    return null;
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

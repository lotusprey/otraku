import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/views/explore_view.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/views/user_view.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class HomeView extends StatefulWidget {
  const HomeView(this.id);

  final int id;

  static const FEED = 0;
  static const ANIME_LIST = 1;
  static const MANGA_LIST = 2;
  static const EXPLORE = 3;
  static const PROFILE = 4;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Get.put(HomeController());
    Get.put(ExploreController());
    Get.put(FeedController(null));
    Get.put(
      UserController(widget.id),
      tag: widget.id.toString(),
    );
    Get.put(
      CollectionController(widget.id, true),
      tag: '${widget.id}true',
    );
    Get.put(
      CollectionController(widget.id, false),
      tag: '${widget.id}false',
    );
  }

  @override
  void dispose() {
    Get.delete<HomeController>();
    Get.delete<ExploreController>();
    Get.delete<FeedController>();
    Get.delete<UserController>(tag: widget.id.toString());
    Get.delete<CollectionController>(tag: '${widget.id}true');
    Get.delete<CollectionController>(tag: '${widget.id}false');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeFeedView(),
      HomeCollectionView(ofAnime: true, id: widget.id, key: UniqueKey()),
      HomeCollectionView(ofAnime: false, id: widget.id, key: UniqueKey()),
      const ExploreView(),
      HomeUserView(widget.id, null),
    ];

    final fabs = [
      null,
      CollectionActionButton('${widget.id}true', key: UniqueKey()),
      CollectionActionButton('${widget.id}false', key: UniqueKey()),
      ExploreActionButton(),
      null,
    ];

    BackgroundHandler.checkIfLaunchedByNotification();

    return GetBuilder<HomeController>(
      id: HomeController.ID_HOME,
      builder: (homeCtrl) => WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: NavLayout(
          index: homeCtrl.homeTab,
          child: tabs[homeCtrl.homeTab],
          floating: fabs[homeCtrl.homeTab],
          onChanged: (i) => homeCtrl.homeTab = i,
          items: const {
            'Feed': Ionicons.file_tray_outline,
            'Anime': Ionicons.film_outline,
            'Manga': Ionicons.bookmark_outline,
            'Explore': Ionicons.compass_outline,
            'Profile': Ionicons.person_outline,
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext ctx) async {
    if (!LocalSettings().confirmExit) return SynchronousFuture(true);

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

    return Future.value(ok);
  }
}

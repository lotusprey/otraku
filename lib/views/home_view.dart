import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/controllers/progress_controller.dart';
import 'package:otraku/controllers/tag_group_controller.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/providers/user_settings.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/explore_view.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/views/inbox_view.dart';
import 'package:otraku/views/user_view.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class HomeView extends StatefulWidget {
  const HomeView(this.id);

  final int id;

  static const INBOX = 0;
  static const ANIME_LIST = 1;
  static const MANGA_LIST = 2;
  static const EXPLORE = 3;
  static const USER = 4;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _ctrl = ScrollController();

  late final HomeController homeCtrl;
  late final ProgressController progressCtrl;
  late final ExploreController exploreCtrl;
  late final FeedController feedCtrl;
  late final TagGroupController tagCtrl;
  late final UserController userCtrl;
  late final CollectionController animeCtrl;
  late final CollectionController mangaCtrl;

  late final List<Widget> tabs;
  late final List<Widget?> fabs;

  @override
  Widget build(BuildContext context) {
    BackgroundHandler.checkIfLaunchedByNotification();

    return Consumer(
      builder: (context, ref, _) {
        ref.watch(userSettingsProvider.notifier);
        return GetBuilder<HomeController>(
          id: HomeController.ID_HOME,
          builder: (homeCtrl) => WillPopScope(
            onWillPop: () => _onWillPop(context),
            child: NavLayout(
              navRow: NavIconRow(
                index: homeCtrl.homeTab,
                onChanged: (i) => homeCtrl.homeTab = i,
                items: const {
                  'Feed': Ionicons.file_tray_outline,
                  'Anime': Ionicons.film_outline,
                  'Manga': Ionicons.bookmark_outline,
                  'Explore': Ionicons.compass_outline,
                  'Profile': Ionicons.person_outline,
                },
                onSame: (i) {
                  switch (i) {
                    case HomeView.ANIME_LIST:
                      if (animeCtrl.scrollCtrl.pos.pixels > 0)
                        animeCtrl.scrollCtrl.scrollUpTo(0);
                      else
                        animeCtrl.search == null
                            ? animeCtrl.search = ''
                            : animeCtrl.search = null;
                      return;
                    case HomeView.MANGA_LIST:
                      if (mangaCtrl.scrollCtrl.pos.pixels > 0)
                        mangaCtrl.scrollCtrl.scrollUpTo(0);
                      else
                        mangaCtrl.search == null
                            ? mangaCtrl.search = ''
                            : mangaCtrl.search = null;
                      return;
                    case HomeView.EXPLORE:
                      if (exploreCtrl.scrollCtrl.pos.pixels > 0)
                        exploreCtrl.scrollCtrl.scrollUpTo(0);
                      else
                        exploreCtrl.search == null
                            ? exploreCtrl.search = ''
                            : exploreCtrl.search = null;
                      return;
                    default:
                      _ctrl.scrollUpTo(0);
                      return;
                  }
                },
              ),
              child: tabs[homeCtrl.homeTab],
              floating: fabs[homeCtrl.homeTab],
              trySubtab: (goRight) {
                if (homeCtrl.homeTab != HomeView.INBOX ||
                    homeCtrl.onFeed == goRight) return false;

                homeCtrl.onFeed = !homeCtrl.onFeed;
                return true;
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop(BuildContext ctx) async {
    if (homeCtrl.homeTab == HomeView.EXPLORE && exploreCtrl.search != null) {
      exploreCtrl.search = null;
      return SynchronousFuture(false);
    }
    if (homeCtrl.homeTab == HomeView.ANIME_LIST && animeCtrl.search != null) {
      animeCtrl.search = null;
      return SynchronousFuture(false);
    }
    if (homeCtrl.homeTab == HomeView.MANGA_LIST && mangaCtrl.search != null) {
      mangaCtrl.search = null;
      return SynchronousFuture(false);
    }

    if (!Settings().confirmExit) return SynchronousFuture(true);

    bool ok = false;
    await showPopUp(
      ctx,
      ConfirmationDialog(
        title: 'Exit?',
        mainAction: 'Yes',
        secondaryAction: 'No',
        onConfirm: () => ok = true,
      ),
    );

    return Future.value(ok);
  }

  @override
  void initState() {
    super.initState();
    homeCtrl = Get.put(HomeController());
    progressCtrl = Get.put(ProgressController());
    exploreCtrl = Get.put(ExploreController());
    feedCtrl = Get.put(FeedController(null));
    tagCtrl = Get.put(TagGroupController());
    userCtrl = Get.put(
      UserController(widget.id),
      tag: widget.id.toString(),
    );
    animeCtrl = Get.put(
      CollectionController(widget.id, true),
      tag: '${widget.id}true',
    );
    mangaCtrl = Get.put(
      CollectionController(widget.id, false),
      tag: '${widget.id}false',
    );

    tabs = [
      InboxView(feedCtrl, _ctrl),
      HomeCollectionView(ofAnime: true, id: widget.id, key: UniqueKey()),
      HomeCollectionView(ofAnime: false, id: widget.id, key: UniqueKey()),
      const ExploreView(),
      HomeUserView(widget.id, null, _ctrl),
    ];

    fabs = [
      null,
      CollectionActionButton('${widget.id}true', key: UniqueKey()),
      CollectionActionButton('${widget.id}false', key: UniqueKey()),
      const ExploreActionButton(),
      null,
    ];
  }

  @override
  void dispose() {
    _ctrl.dispose();
    Get.delete<HomeController>();
    Get.delete<ProgressController>();
    Get.delete<ExploreController>();
    Get.delete<FeedController>();
    Get.delete<TagGroupController>();
    Get.delete<UserController>(tag: widget.id.toString());
    Get.delete<CollectionController>(tag: '${widget.id}true');
    Get.delete<CollectionController>(tag: '${widget.id}false');
    super.dispose();
  }
}

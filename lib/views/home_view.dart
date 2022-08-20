import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/controllers/progress_controller.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/discover/discover_providers.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/tag/tag_provider.dart';
import 'package:otraku/user/user_providers.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/discover/discover_view.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/views/inbox_view.dart';
import 'package:otraku/user/user_view.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView(this.id);

  final int id;

  static const INBOX = 0;
  static const ANIME_LIST = 1;
  static const MANGA_LIST = 2;
  static const DISCOVER = 3;
  static const USER = 4;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late final _ctrl = PaginationController(loadMore: _scrollListener);

  late final HomeController homeCtrl;
  late final ProgressController progressCtrl;
  late final CollectionController animeCtrl;
  late final CollectionController mangaCtrl;

  @override
  void initState() {
    super.initState();
    homeCtrl = Get.put(HomeController());
    progressCtrl = Get.put(ProgressController());
    animeCtrl = Get.put(
      CollectionController(widget.id, true),
      tag: '${widget.id}true',
    );
    mangaCtrl = Get.put(
      CollectionController(widget.id, false),
      tag: '${widget.id}false',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    Get.delete<HomeController>();
    Get.delete<ProgressController>();
    Get.delete<CollectionController>(tag: '${widget.id}true');
    Get.delete<CollectionController>(tag: '${widget.id}false');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BackgroundHandler.checkIfLaunchedByNotification();

    return Consumer(
      builder: (context, ref, _) {
        _keepHomeProvidersAlive(ref);

        return GetBuilder<HomeController>(
          id: HomeController.ID_HOME,
          builder: (homeCtrl) {
            return WillPopScope(
              onWillPop: () => _onWillPop(context),
              child: PageLayout(
                bottomBar: BottomBarIconTabs(
                  current: homeCtrl.homeTab,
                  onChanged: (i) => homeCtrl.homeTab = i,
                  items: const {
                    'Feed': Ionicons.file_tray_outline,
                    'Anime': Ionicons.film_outline,
                    'Manga': Ionicons.bookmark_outline,
                    'Discover': Ionicons.compass_outline,
                    'Profile': Ionicons.person_outline,
                  },
                  onSame: (i) {
                    switch (i) {
                      case HomeView.ANIME_LIST:
                        if (_ctrl.position.pixels > 0)
                          _ctrl.scrollToTop();
                        else
                          animeCtrl.search == null
                              ? animeCtrl.search = ''
                              : animeCtrl.search = null;
                        return;
                      case HomeView.MANGA_LIST:
                        if (_ctrl.position.pixels > 0)
                          _ctrl.scrollToTop();
                        else
                          mangaCtrl.search == null
                              ? mangaCtrl.search = ''
                              : mangaCtrl.search = null;
                        return;
                      case HomeView.DISCOVER:
                        if (_ctrl.position.pixels > 0) {
                          _ctrl.scrollToTop();
                        } else {
                          final notifier = ref.read(
                            discoverSearchFilterProvider.notifier,
                          );
                          notifier.state == null
                              ? notifier.state = ''
                              : notifier.state = null;
                        }
                        return;
                      default:
                        _ctrl.scrollToTop();
                        return;
                    }
                  },
                ),
                child: DirectPageView(
                  current: homeCtrl.homeTab,
                  onChanged: (i) => homeCtrl.homeTab = i,
                  children: [
                    InboxView(_ctrl),
                    CollectionSubView(
                      scrollCtrl: _ctrl,
                      ctrlTag: '${widget.id}true',
                      key: Key(true.toString()),
                    ),
                    CollectionSubView(
                      scrollCtrl: _ctrl,
                      ctrlTag: '${widget.id}false',
                      key: Key(false.toString()),
                    ),
                    DiscoverView(_ctrl),
                    UserSubView(widget.id, null, _ctrl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _keepHomeProvidersAlive(WidgetRef ref) {
    ref.watch(userSettingsProvider.select((_) => null));
    ref.watch(tagsProvider.select((_) => null));
    ref.watch(activitiesProvider(null).select((_) => null));
    ref.watch(userProvider(widget.id).select((_) => null));
    final discoverType = ref.watch(discoverTypeProvider);
    switch (discoverType) {
      case DiscoverType.anime:
        return ref.watch(discoverAnimeProvider.select((_) => null));
      case DiscoverType.manga:
        return ref.watch(discoverMangaProvider.select((_) => null));
      case DiscoverType.character:
        return ref.watch(discoverCharacterProvider.select((_) => null));
      case DiscoverType.staff:
        return ref.watch(discoverStaffProvider.select((_) => null));
      case DiscoverType.studio:
        return ref.watch(discoverStudioProvider.select((_) => null));
      case DiscoverType.user:
        return ref.watch(discoverUserProvider.select((_) => null));
      case DiscoverType.review:
        return ref.watch(discoverReviewProvider.select((_) => null));
    }
  }

  void _scrollListener() {
    if (homeCtrl.homeTab == HomeView.INBOX && homeCtrl.onFeed) {
      ref.read(activitiesProvider(null).notifier).fetch();
    } else if (homeCtrl.homeTab == HomeView.DISCOVER) {
      discoverLoadMore(ref);
    }
  }

  Future<bool> _onWillPop(BuildContext ctx) async {
    if (homeCtrl.homeTab == HomeView.DISCOVER) {
      final notifier = ref.read(discoverSearchFilterProvider.notifier);
      if (notifier.state != null) {
        notifier.state = null;
        return Future.value(false);
      }
    }
    if (homeCtrl.homeTab == HomeView.ANIME_LIST && animeCtrl.search != null) {
      animeCtrl.search = null;
      return Future.value(false);
    }
    if (homeCtrl.homeTab == HomeView.MANGA_LIST && mangaCtrl.search != null) {
      mangaCtrl.search = null;
      return Future.value(false);
    }

    if (!Settings().confirmExit) return Future.value(true);

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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/collection/collection_providers.dart';
import 'package:otraku/collection/progress_provider.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/discover/discover_providers.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/tag/tag_provider.dart';
import 'package:otraku/user/user_providers.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/discover/discover_view.dart';
import 'package:otraku/collection/collection_view.dart';
import 'package:otraku/feed/feed_view.dart';
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
  late final animeEntriesTag = CollectionTag(widget.id, true);
  late final mangaEntriesTag = CollectionTag(widget.id, false);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BackgroundHandler.handleNotificationLaunch();

    if (Options().lastVersionCode != versionCode) {
      BackgroundHandler.checkPermission().then((hasPermission) {
        if (!hasPermission && mounted) {
          showPopUp(
            context,
            ConfirmationDialog(
              title: 'Allow notifications?',
              secondaryAction: 'No',
              onConfirm: () => BackgroundHandler.requestPermission().then(
                (success) {
                  if (!success && mounted) {
                    showPopUp(
                      context,
                      const ConfirmationDialog(
                        title: 'Could not acquire permission',
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
        Options().updateVersionCode();
      });
    }

    // Keep important providers alive.
    ref.watch(settingsProvider.select((_) => null));
    ref.watch(tagsProvider.select((_) => null));
    ref.watch(progressProvider.select((_) => null));
    ref.watch(activitiesProvider(null).select((_) => null));
    ref.watch(userProvider(widget.id).select((_) => null));
    ref.watch(entriesProvider(animeEntriesTag).select((_) => null));
    ref.watch(entriesProvider(mangaEntriesTag).select((_) => null));
    final discoverType = ref.watch(discoverTypeProvider);
    switch (discoverType) {
      case DiscoverType.anime:
        ref.watch(discoverAnimeProvider.select((_) => null));
        break;
      case DiscoverType.manga:
        ref.watch(discoverMangaProvider.select((_) => null));
        break;
      case DiscoverType.character:
        ref.watch(discoverCharacterProvider.select((_) => null));
        break;
      case DiscoverType.staff:
        ref.watch(discoverStaffProvider.select((_) => null));
        break;
      case DiscoverType.studio:
        ref.watch(discoverStudioProvider.select((_) => null));
        break;
      case DiscoverType.user:
        ref.watch(discoverUserProvider.select((_) => null));
        break;
      case DiscoverType.review:
        ref.watch(discoverReviewProvider.select((_) => null));
        break;
    }

    final notifier = ref.watch(homeProvider);

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: PageLayout(
        bottomBar: BottomBarIconTabs(
          current: notifier.homeTab,
          onChanged: (i) => ref.read(homeProvider).homeTab = i,
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
                if (_ctrl.position.pixels > 0) {
                  _ctrl.scrollToTop();
                } else {
                  ref
                      .read(searchProvider(animeEntriesTag).notifier)
                      .update((s) => s == null ? '' : null);
                }
                return;
              case HomeView.MANGA_LIST:
                if (_ctrl.position.pixels > 0) {
                  _ctrl.scrollToTop();
                } else {
                  ref
                      .read(searchProvider(mangaEntriesTag).notifier)
                      .update((s) => s == null ? '' : null);
                }
                return;
              case HomeView.DISCOVER:
                if (_ctrl.position.pixels > 0) {
                  _ctrl.scrollToTop();
                } else {
                  ref
                      .read(searchProvider(null).notifier)
                      .update((s) => s == null ? '' : null);
                }
                return;
              default:
                _ctrl.scrollToTop();
                return;
            }
          },
        ),
        child: DirectPageView(
          current: notifier.homeTab,
          onChanged: (i) => ref.read(homeProvider).homeTab = i,
          children: [
            FeedView(_ctrl),
            CollectionSubView(
              scrollCtrl: _ctrl,
              tag: CollectionTag(widget.id, true),
              key: Key(true.toString()),
            ),
            CollectionSubView(
              scrollCtrl: _ctrl,
              tag: CollectionTag(widget.id, false),
              key: Key(false.toString()),
            ),
            DiscoverView(_ctrl),
            UserSubView(widget.id, null, _ctrl),
          ],
        ),
      ),
    );
  }

  void _scrollListener() {
    final notifier = ref.read(homeProvider);
    if (notifier.homeTab == HomeView.INBOX && notifier.inboxOnFeed) {
      ref.read(activitiesProvider(null).notifier).fetch();
    } else if (notifier.homeTab == HomeView.DISCOVER) {
      discoverLoadMore(ref);
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final notifier = ref.read(homeProvider);
    if (notifier.homeTab == HomeView.DISCOVER) {
      final notifier = ref.read(searchProvider(null).notifier);
      if (notifier.state != null) {
        notifier.state = null;
        return Future.value(false);
      }
    }
    if (notifier.homeTab == HomeView.ANIME_LIST) {
      final notifier = ref.read(searchProvider(animeEntriesTag).notifier);
      if (notifier.state != null) {
        notifier.state = null;
        return Future.value(false);
      }
    }
    if (notifier.homeTab == HomeView.MANGA_LIST) {
      final notifier = ref.read(searchProvider(mangaEntriesTag).notifier);
      if (notifier.state != null) {
        notifier.state = null;
        return Future.value(false);
      }
    }

    if (!Options().confirmExit) return Future.value(true);

    bool ok = false;
    await showPopUp(
      context,
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

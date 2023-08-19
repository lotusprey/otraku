import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/activity/activities_providers.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/collection/collection_preview_provider.dart';
import 'package:otraku/modules/collection/collection_preview_view.dart';
import 'package:otraku/modules/collection/collection_providers.dart';
import 'package:otraku/modules/discover/discover_providers.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/modules/tag/tag_provider.dart';
import 'package:otraku/modules/user/user_providers.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/discover/discover_view.dart';
import 'package:otraku/modules/collection/collection_view.dart';
import 'package:otraku/modules/feed/feed_view.dart';
import 'package:otraku/modules/user/user_view.dart';
import 'package:otraku/common/utils/background_handler.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView(this.id);

  final int id;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late final _animeCollectionTag = (userId: widget.id, ofAnime: true);
  late final _mangaCollectionTag = (userId: widget.id, ofAnime: false);
  final _animeScrollCtrl = ScrollController();
  final _mangaScrollCtrl = ScrollController();
  late final _feedScrollCtrl = PagedController(
    loadMore: () => ref.read(activitiesProvider(null).notifier).fetch(),
  );
  late final _discoverScrollCtrl = PagedController(
    loadMore: () => ref.read(discoverProvider.notifier).fetch(),
  );
  late final _tabCtrl = TabController(
    length: HomeTab.values.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabCtrl.index = ref.read(homeProvider.notifier).homeTab.index;
    _tabCtrl.addListener(
      () => ref.read(homeProvider).homeTab = HomeTab.values[_tabCtrl.index],
    );
  }

  @override
  void dispose() {
    BackgroundHandler.clearNotifications();
    _animeScrollCtrl.dispose();
    _mangaScrollCtrl.dispose();
    _feedScrollCtrl.dispose();
    _discoverScrollCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BackgroundHandler.handleNotificationLaunch();

    if (Options().lastVersionCode != versionCode) {
      BackgroundHandler.checkPermission().then((hasPermission) {
        if (!hasPermission) {
          BackgroundHandler.requestPermission().then((success) {
            if (!success && mounted) {
              showPopUp(
                context,
                const ConfirmationDialog(
                  title: 'No permission to send notifications',
                ),
              );
            }
          });
        }
        Options().updateVersionCode();
      });
    }

    ref.listen(
      homeProvider.select((s) => s.homeTab),
      (_, tab) => _tabCtrl.index = tab.index,
    );

    ref.watch(settingsProvider.select((_) => null));
    ref.watch(tagsProvider.select((_) => null));
    ref.watch(userProvider(widget.id).select((_) => null));

    final notifier = ref.watch(homeProvider);
    notifier.checkLazyTabs();

    if (notifier.didOpenFeed) {
      ref.watch(activitiesProvider(null).select((_) => null));
    }

    if (notifier.didOpenDiscover) {
      ref.watch(discoverProvider.select((_) => null));
    }

    notifier.didExpandCollection(true)
        ? ref.watch(entriesProvider(_animeCollectionTag).select((_) => null))
        : ref.watch(
            collectionPreviewProvider(_animeCollectionTag).select((_) => null),
          );

    notifier.didExpandCollection(false)
        ? ref.watch(entriesProvider(_mangaCollectionTag).select((_) => null))
        : ref.watch(
            collectionPreviewProvider(_mangaCollectionTag).select((_) => null),
          );

    final primaryScrollCtrl = PrimaryScrollController.of(context);

    return WillPopScope(
      onWillPop: () => _onWillPopHome(context),
      child: PageScaffold(
        bottomBar: BottomNavBar(
          current: notifier.homeTab.index,
          onChanged: (i) => ref.read(homeProvider).homeTab = HomeTab.values[i],
          items: {
            for (final t in HomeTab.values) t.title: t.iconData,
          },
          onSame: (i) {
            final tab = HomeTab.values[i];

            switch (tab) {
              case HomeTab.anime:
                if (_animeScrollCtrl.position.pixels > 0) {
                  _animeScrollCtrl.scrollToTop();
                } else if (ref.read(homeProvider).didExpandCollection(true)) {
                  _updateCollectionSearch(
                    _animeCollectionTag,
                    (search) => search == null ? '' : null,
                  );
                }
                return;
              case HomeTab.manga:
                if (_mangaScrollCtrl.position.pixels > 0) {
                  _mangaScrollCtrl.scrollToTop();
                } else if (ref.read(homeProvider).didExpandCollection(false)) {
                  _updateCollectionSearch(
                    _mangaCollectionTag,
                    (search) => search == null ? '' : null,
                  );
                }
                return;
              case HomeTab.discover:
                if (_discoverScrollCtrl.position.pixels > 0) {
                  _discoverScrollCtrl.scrollToTop();
                } else {
                  ref.read(discoverFilterProvider.notifier).update(
                        (s) => s.copyWith(
                          search: () => s.search == null ? '' : null,
                        ),
                      );
                }
                return;
              case HomeTab.feed:
                _feedScrollCtrl.scrollToTop();
              case HomeTab.profile:
                primaryScrollCtrl.scrollToTop();
                return;
            }
          },
        ),
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            FeedView(_feedScrollCtrl),
            if (notifier.didExpandCollection(true))
              CollectionSubView(
                scrollCtrl: _animeScrollCtrl,
                tag: _animeCollectionTag,
                key: Key(true.toString()),
              )
            else
              CollectionPreviewView(
                scrollCtrl: _animeScrollCtrl,
                tag: _animeCollectionTag,
                key: Key(true.toString()),
              ),
            if (notifier.didExpandCollection(false))
              CollectionSubView(
                scrollCtrl: _mangaScrollCtrl,
                tag: _mangaCollectionTag,
                key: Key(false.toString()),
              )
            else
              CollectionPreviewView(
                scrollCtrl: _mangaScrollCtrl,
                tag: _mangaCollectionTag,
                key: Key(false.toString()),
              ),
            DiscoverView(_discoverScrollCtrl),
            UserSubView(widget.id, null, primaryScrollCtrl),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPopHome(BuildContext context) async {
    final notifier = ref.read(homeProvider);
    if (notifier.homeTab == HomeTab.discover) {
      final notifier = ref.read(discoverFilterProvider.notifier);
      if (notifier.state.search != null) {
        notifier.state = notifier.state.copyWith(search: () => null);
        return Future.value(false);
      }
    }

    if (notifier.homeTab == HomeTab.anime &&
        notifier.didExpandCollection(true)) {
      final notifier = ref.read(
        collectionFilterProvider(_animeCollectionTag).notifier,
      );
      if (notifier.state.search != null) {
        notifier.state = notifier.state.copyWith(search: () => null);
        return Future.value(false);
      }
    }

    if (notifier.homeTab == HomeTab.manga &&
        notifier.didExpandCollection(false)) {
      final notifier = ref.read(
        collectionFilterProvider(_mangaCollectionTag).notifier,
      );
      if (notifier.state.search != null) {
        notifier.state = notifier.state.copyWith(search: () => null);
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

  void _updateCollectionSearch(
    CollectionTag tag,
    String? Function(String?) callback,
  ) =>
      ref
          .read(collectionFilterProvider(tag).notifier)
          .update((s) => s.copyWith(search: () => callback(s.search)));
}

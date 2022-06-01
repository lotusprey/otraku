import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activities/activities_view.dart';
import 'package:otraku/collections/entry_item.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/collections/entry.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/edit/edit.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/controllers/progress_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/grids/minimal_collection_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';

class InboxView extends StatelessWidget {
  InboxView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final notificationIcon = Consumer(
      builder: (context, ref, child) {
        final count = ref.watch(
          userSettingsProvider.select((s) => s.notificationCount),
        );

        final openNotifications = () {
          ref.read(userSettingsProvider.notifier).nullifyUnread();
          Navigator.pushNamed(context, RouteArg.notifications);
        };

        if (count < 1)
          return TopBarIcon(
            tooltip: 'Notifications',
            icon: Ionicons.notifications_outline,
            onTap: openNotifications,
          );

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Tooltip(
            message: 'Notifications',
            child: GestureDetector(
              onTap: openNotifications,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    child: Icon(
                      Ionicons.notifications_outline,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                      maxHeight: 20,
                    ),
                    margin: const EdgeInsets.only(right: 15, bottom: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: Theme.of(context).colorScheme.background,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return GetBuilder<HomeController>(
      id: HomeController.ID_HOME,
      builder: (homeCtrl) {
        return PageLayout(
          floatingBar: FloatingBar(
            scrollCtrl: scrollCtrl,
            children: [
              ActionMenu(
                current: homeCtrl.onFeed ? 1 : 0,
                onChanged: (page) => homeCtrl.onFeed = page == 1,
                items: const {
                  'Progress': Ionicons.tv_outline,
                  'Feed': Ionicons.chatbubble_outline,
                },
              ),
            ],
          ),
          topBar: TopBar(
            canPop: false,
            title: homeCtrl.onFeed ? 'Feed' : 'Progress',
            items: [
              if (homeCtrl.onFeed)
                Consumer(
                  builder: (context, ref, _) => TopBarIcon(
                    tooltip: 'Filter',
                    icon: Ionicons.funnel_outline,
                    onTap: () => showActivityFilterSheet(context, ref, null),
                  ),
                )
              else
                const SizedBox(width: 45),
              notificationIcon,
            ],
          ),
          child: _InboxTabView(homeCtrl, scrollCtrl),
        );
      },
    );
  }
}

class _InboxTabView extends StatefulWidget {
  const _InboxTabView(this.homeCtrl, this.scrollCtrl);

  final HomeController homeCtrl;
  final ScrollController scrollCtrl;

  @override
  State<_InboxTabView> createState() => __InboxTabViewState();
}

class __InboxTabViewState extends State<_InboxTabView> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: widget.homeCtrl.onFeed ? 1 : 0);
  }

  @override
  void didUpdateWidget(covariant _InboxTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ctrl.animateToPage(
      widget.homeCtrl.onFeed ? 1 : 0,
      curve: Curves.easeOutExpo,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _ctrl,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (page) => widget.homeCtrl.onFeed = page == 1,
      children: [
        _ProgressView(widget.scrollCtrl),
        ActivitiesSubView(null, widget.scrollCtrl),
      ],
    );
  }
}

class _ProgressView extends StatelessWidget {
  _ProgressView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    const titlePadding = EdgeInsets.symmetric(vertical: 10);
    final titleStyle = Theme.of(context).textTheme.headline2;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: GetBuilder<ProgressController>(
        builder: (ctrl) {
          if (ctrl.releasingAnime.isEmpty &&
              ctrl.otherAnime.isEmpty &&
              ctrl.releasingManga.isEmpty &&
              ctrl.otherManga.isEmpty) {
            if (ctrl.isLoading) return const Center(child: Loader());

            return const Text('You aren\'t watching/reading anything');
          }

          return CustomScrollView(
            physics: Consts.physics,
            controller: scrollCtrl,
            slivers: [
              SliverRefreshControl(
                onRefresh: () => ctrl.fetch(),
                canRefresh: () => !ctrl.isLoading,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: titlePadding,
                  child: Text('Releasing Anime', style: titleStyle),
                ),
              ),
              MinimalCollectionGrid(
                items: ctrl.releasingAnime,
                updateProgress: _updateAnimeProgress,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: titlePadding,
                  child: Text('Other Anime', style: titleStyle),
                ),
              ),
              MinimalCollectionGrid(
                items: ctrl.otherAnime,
                updateProgress: _updateAnimeProgress,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: titlePadding,
                  child: Text('Releasing Manga', style: titleStyle),
                ),
              ),
              MinimalCollectionGrid(
                items: ctrl.releasingManga,
                updateProgress: _updateMangaProgress,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: titlePadding,
                  child: Text('Other Manga', style: titleStyle),
                ),
              ),
              MinimalCollectionGrid(
                items: ctrl.otherManga,
                updateProgress: _updateMangaProgress,
              ),
              const SliverFooter(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateAnimeProgress(EntryItem e) async {
    final customLists = await updateProgress(e.mediaId, e.progress);
    if (customLists == null) return;

    Get.find<CollectionController>(tag: '${Settings().id}true').updateProgress(
      e.mediaId,
      e.progress,
      customLists,
      EntryStatus.CURRENT,
      null,
    );
  }

  Future<void> _updateMangaProgress(EntryItem e) async {
    final customLists = await updateProgress(e.mediaId, e.progress);
    if (customLists == null) return;

    Get.find<CollectionController>(tag: '${Settings().id}false').updateProgress(
      e.mediaId,
      e.progress,
      customLists,
      EntryStatus.CURRENT,
      null,
    );
  }
}

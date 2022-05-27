import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activities/activities_view.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/list_status.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/controllers/progress_controller.dart';
import 'package:otraku/models/progress_entry_model.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/grids/minimal_collection_grid.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_loaders.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';

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
      builder: (ctrl) {
        return PageLayout(
          topBar: TopBar(
            canPop: false,
            items: [
              Expanded(
                child: TabSegments(
                  items: const {'Progress': false, 'Feed': true},
                  initial: ctrl.onFeed,
                  onChanged: (bool val) => ctrl.onFeed = val,
                ),
              ),
              if (ctrl.onFeed)
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: ctrl.onFeed
                ? ActivitiesSubView(null, scrollCtrl)
                : _ProgressView(scrollCtrl),
          ),
        );
      },
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

  Future<void> _updateAnimeProgress(ProgressEntryModel e) async {
    await Get.find<CollectionController>(tag: '${Settings().id}true')
        .updateProgress(e.mediaId, e.progress, ListStatus.CURRENT, e.format);
  }

  Future<void> _updateMangaProgress(ProgressEntryModel e) async {
    await Get.find<CollectionController>(tag: '${Settings().id}false')
        .updateProgress(e.mediaId, e.progress, ListStatus.CURRENT, e.format);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/list_status.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/controllers/progress_controller.dart';
import 'package:otraku/models/progress_entry_model.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/widgets/activity_box.dart';
import 'package:otraku/widgets/layouts/minimal_collection_grid.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';
import 'package:otraku/widgets/navigation/header_layout.dart';

class InboxView extends StatelessWidget {
  InboxView(this.feedCtrl, this.scrollCtrl);

  final FeedController feedCtrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final notificationIcon = GetBuilder<HomeController>(
      id: HomeController.ID_NOTIFICATIONS,
      builder: (homeCtrl) {
        if (homeCtrl.notificationCount < 1)
          return AppBarIcon(
            tooltip: 'Notifications',
            icon: Ionicons.notifications_outline,
            onTap: () => Navigator.pushNamed(context, RouteArg.notifications),
          );

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Tooltip(
            message: 'Notifications',
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, RouteArg.notifications),
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
                        homeCtrl.notificationCount.toString(),
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
        return HeaderLayout(
          topItems: [
            Expanded(
              child: TabSegments(
                items: const {'Progress': false, 'Feed': true},
                initial: ctrl.onFeed,
                onChanged: (bool val) => ctrl.onFeed = val,
              ),
            ),
            if (ctrl.onFeed)
              FeedFilterIcon(feedCtrl)
            else
              const SizedBox(width: 45),
            notificationIcon,
          ],
          builder: (context, offsetTop) => AnimatedSwitcher(
            duration: Consts.TRANSITION_DURATION,
            child: ctrl.onFeed
                ? _FeedView(feedCtrl, scrollCtrl, offsetTop)
                : _ProgressView(scrollCtrl, offsetTop),
          ),
        );
      },
    );
  }
}

class _ProgressView extends StatelessWidget {
  _ProgressView(this.scrollCtrl, this.offsetTop);

  final ScrollController scrollCtrl;
  final double offsetTop;

  @override
  Widget build(BuildContext context) {
    const titlePadding = EdgeInsets.symmetric(vertical: 10);
    final titleStyle = Theme.of(context).textTheme.headline2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GetBuilder<ProgressController>(
        builder: (ctrl) {
          if (ctrl.releasingAnime.isEmpty &&
              ctrl.otherAnime.isEmpty &&
              ctrl.releasingManga.isEmpty &&
              ctrl.otherManga.isEmpty) {
            if (ctrl.isLoading) return const Center(child: Loader());

            return const Text('You are not watching/reading anything');
          }

          return CustomScrollView(
            physics: Consts.PHYSICS,
            controller: scrollCtrl,
            slivers: [
              SliverRefreshControl(
                onRefresh: () => ctrl.fetch(),
                canRefresh: () => !ctrl.isLoading,
                offsetTop: offsetTop - 10,
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
              SliverToBoxAdapter(
                child: SizedBox(height: NavLayout.offset(context)),
              ),
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

class _FeedView extends StatefulWidget {
  _FeedView(this.ctrl, this.scrollCtrl, this.offsetTop);

  final FeedController ctrl;
  final ScrollController scrollCtrl;
  final double offsetTop;

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> {
  Future<void> _listener() async {
    if (widget.ctrl.isLoading ||
        widget.scrollCtrl.position.pixels <
            widget.scrollCtrl.position.maxScrollExtent - 100)
      return Future.value();

    await widget.ctrl.fetchPage();
  }

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.addListener(_listener);
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      id: FeedController.ID_ACTIVITIES,
      builder: (feedCtrl) {
        late Widget content;

        final activities = feedCtrl.activities;
        if (activities.isEmpty) {
          if (feedCtrl.isLoading) {
            content = const SliverFillRemaining(child: Center(child: Loader()));
          } else {
            content = SliverFillRemaining(
              child: Center(
                child: Text(
                  'No Activities',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            );
          }
        } else {
          content = SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => ActivityBox(ctrl: feedCtrl, model: activities[i]),
              childCount: activities.length,
            ),
          );
        }

        return CustomScrollView(
          physics: Consts.PHYSICS,
          controller: widget.scrollCtrl,
          slivers: [
            SliverRefreshControl(
              onRefresh: () => widget.ctrl.fetchPage(clean: true),
              canRefresh: () => !widget.ctrl.isLoading,
              offsetTop: widget.offsetTop - 10,
            ),
            SliverPadding(padding: Consts.PADDING, sliver: content),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: NavLayout.offset(context) + 10,
              ),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child:
                      feedCtrl.hasNextPage ? const Loader() : const SizedBox(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

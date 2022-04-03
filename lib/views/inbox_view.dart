import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/list_status.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/widgets/activity_box.dart';
import 'package:otraku/widgets/layouts/collection_grid.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';
import 'package:otraku/widgets/navigation/translucent_layout.dart';

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
        return TranslucentLayout(
          headerItems: [
            Expanded(
              child: TabSegments(
                items: const {'Progress': false, 'Feed': true},
                current: () => ctrl.onFeed,
                onChanged: (bool val) => ctrl.onFeed = val,
              ),
            ),
            if (ctrl.onFeed)
              FeedFilterIcon(feedCtrl)
            else
              const SizedBox(width: 45),
            notificationIcon,
          ],
          builder: (offsetTop) {
            if (ctrl.onFeed)
              return CustomScrollView(
                physics: Consts.PHYSICS,
                controller: scrollCtrl,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: offsetTop)),
                  ..._feedWidgets(context),
                  SliverToBoxAdapter(
                    child: SizedBox(height: NavLayout.offset(context)),
                  ),
                ],
              );

            return GetBuilder<CollectionController>(
              id: CollectionController.ID_BODY,
              tag: '${Settings().id}true',
              builder: (animeCtrl) => GetBuilder<CollectionController>(
                id: CollectionController.ID_BODY,
                tag: '${Settings().id}false',
                builder: (mangaCtrl) => CustomScrollView(
                  physics: Consts.PHYSICS,
                  controller: scrollCtrl,
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: offsetTop)),
                    ..._progressWidgets(context, animeCtrl, mangaCtrl),
                    SliverToBoxAdapter(
                      child: SizedBox(height: NavLayout.offset(context)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _feedWidgets(BuildContext context) => [
        SliverRefreshControl(
          onRefresh: () => feedCtrl.fetchPage(clean: true),
          canRefresh: () => !feedCtrl.isLoading,
        ),
        SliverPadding(
          padding: Consts.PADDING,
          sliver: GetBuilder<FeedController>(
            id: FeedController.ID_ACTIVITIES,
            builder: (feedCtrl) {
              if (feedCtrl.isLoading)
                return const SliverFillRemaining(
                  child: Center(child: Loader()),
                );

              final activities = feedCtrl.activities;
              if (activities.isEmpty)
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No Activities',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                );

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ActivityBox(ctrl: feedCtrl, model: activities[i]),
                  childCount: activities.length,
                ),
              );
            },
          ),
        )
      ];

  List<Widget> _progressWidgets(
    BuildContext context,
    CollectionController animeCtrl,
    CollectionController mangaCtrl,
  ) {
    final slivers = <Widget>[];

    if (animeCtrl.isLoading)
      slivers.add(const SliverToBoxAdapter(child: Loader()));
    else {
      final entries = animeCtrl.listWithStatus(ListStatus.CURRENT);
      if (entries.isNotEmpty) {
        final releasing = <ListEntryModel>[];
        final other = <ListEntryModel>[];
        for (final e in entries)
          e.status == MediaStatus.RELEASING.name
              ? releasing.add(e)
              : other.add(e);

        _addProgressSection(
          title: 'Your current releasing anime',
          items: releasing,
          context: context,
          slivers: slivers,
          ctrl: animeCtrl,
        );
        _addProgressSection(
          title: 'Your current other anime',
          items: other,
          context: context,
          slivers: slivers,
          ctrl: animeCtrl,
        );
      }
    }

    if (mangaCtrl.isLoading && slivers.length > 1)
      slivers.add(const SliverToBoxAdapter(child: Loader()));
    else {
      final entries = mangaCtrl.listWithStatus(ListStatus.CURRENT);
      if (entries.isNotEmpty) {
        final releasing = <ListEntryModel>[];
        final other = <ListEntryModel>[];
        for (final e in entries)
          e.status == MediaStatus.RELEASING.name
              ? releasing.add(e)
              : other.add(e);

        _addProgressSection(
          title: 'Your current releasing manga',
          items: releasing,
          context: context,
          slivers: slivers,
          ctrl: mangaCtrl,
        );
        _addProgressSection(
          title: 'Your current other manga',
          items: other,
          context: context,
          slivers: slivers,
          ctrl: mangaCtrl,
        );
      }
    }

    if (slivers.isEmpty)
      slivers.add(const SliverFillRemaining(
        child: Center(
          child: Text('You don\'t watch/read anything in the moment.'),
        ),
      ));

    return slivers;
  }

  void _addProgressSection({
    required BuildContext context,
    required List<Widget> slivers,
    required String title,
    required List<ListEntryModel> items,
    required CollectionController ctrl,
  }) {
    if (items.isEmpty) return;

    slivers.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(title, style: Theme.of(context).textTheme.headline1),
      ),
    ));

    slivers.add(SliverPadding(
      padding: Consts.PADDING,
      sliver: CollectionGrid(
        items: items,
        scoreFormat: ctrl.scoreFormat!,
        updateProgress: ctrl.updateProgress,
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/widgets/activity_box.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';

class InboxView extends StatelessWidget {
  InboxView({
    required this.feedCtrl,
    required this.animeCtrl,
    required this.mangaCtrl,
    required this.scrollCtrl,
  });

  final FeedController feedCtrl;
  final CollectionController animeCtrl;
  final CollectionController mangaCtrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final notificationWidget = GetBuilder<HomeController>(
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
        return CustomScrollView(
          physics: Consts.PHYSICS,
          controller: scrollCtrl,
          slivers: [
            TranslucentSliverAppBar(
              constrained: true,
              children: [
                Expanded(
                  child: TabSegments(
                    items: const {'Progress': false, 'Feed': true},
                    current: () => ctrl.onFeed,
                    onChanged: (bool val) => ctrl.onFeed = val,
                  ),
                ),
                if (ctrl.onFeed)
                  FeedFilter(feedCtrl)
                else
                  const SizedBox(width: 45),
                notificationWidget,
              ],
            ),
            if (ctrl.onFeed) ...[
              SliverRefreshControl(
                onRefresh: () => feedCtrl.fetchPage(clean: true),
                canRefresh: () => !feedCtrl.isLoading,
              ),
              SliverPadding(
                padding: Consts.PADDING,
                sliver: GetBuilder<FeedController>(
                  id: FeedController.ID_ACTIVITIES,
                  builder: (ctrl) {
                    final activities = ctrl.activities;

                    if (ctrl.isLoading)
                      return const SliverFillRemaining(
                        child: Center(child: Loader()),
                      );

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
                        (_, i) => ActivityBox(ctrl: ctrl, model: activities[i]),
                        childCount: activities.length,
                      ),
                    );
                  },
                ),
              )
            ] else ...[
              const SliverToBoxAdapter(),
            ],
            SliverToBoxAdapter(
              child: SizedBox(height: NavLayout.offset(context)),
            ),
          ],
        );
      },
    );
  }
}

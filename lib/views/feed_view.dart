import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/constants/activity_type.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/activity_box.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';

class FeedView extends StatelessWidget {
  FeedView(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      init: FeedController(id),
      tag: id.toString(),
      builder: (ctrl) => Scaffold(
        appBar: ShadowAppBar(title: 'Activities', actions: [_Filter(ctrl)]),
        body: SafeArea(
          child: GetBuilder<FeedController>(
            id: FeedController.ID_ACTIVITIES,
            tag: id.toString(),
            builder: (ctrl) {
              final activities = ctrl.activities;

              if (ctrl.isLoading) return const Center(child: Loader());

              if (activities.isEmpty)
                return Center(
                  child: Text(
                    'No Activities',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                );

              return ListView.builder(
                physics: Consts.PHYSICS,
                padding: Consts.PADDING,
                controller: ctrl.scrollCtrl,
                itemBuilder: (_, i) =>
                    ActivityBox(feed: ctrl, model: ctrl.activities[i]),
                itemCount: ctrl.activities.length,
              );
            },
          ),
        ),
      ),
    );
  }
}

class HomeFeedView extends StatelessWidget {
  const HomeFeedView();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      builder: (ctrl) => CustomScrollView(
        controller: ctrl.scrollCtrl,
        physics: Consts.PHYSICS,
        slivers: [
          _Header(ctrl),
          SliverRefreshControl(
            onRefresh: () => ctrl.fetchPage(clean: true),
            canRefresh: () => !ctrl.isLoading,
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
                    (_, i) => ActivityBox(feed: ctrl, model: activities[i]),
                    childCount: activities.length,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: NavLayout.offset(context)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  _Header(this.ctrl);

  final FeedController ctrl;

  @override
  Widget build(BuildContext context) {
    return SliverTransparentAppBar([
      BubbleTabs(
        items: const {'Following': true, 'Global': false},
        current: () => ctrl.onFollowing,
        onChanged: (bool val) => ctrl.onFollowing = val,
        onSame: () => ctrl.scrollUpTo(0),
      ),
      const Spacer(),
      _Filter(ctrl),
      GetBuilder<HomeController>(
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
                onTap: () =>
                    Navigator.pushNamed(context, RouteArg.notifications),
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
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
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
      ),
    ]);
  }
}

class _Filter extends StatelessWidget {
  _Filter(this.ctrl);

  final FeedController ctrl;

  @override
  Widget build(BuildContext context) {
    return AppBarIcon(
      tooltip: 'Filter',
      icon: Ionicons.funnel_outline,
      onTap: () => Sheet.show(
        ctx: context,
        sheet: SelectionSheet<ActivityType>(
          options: ActivityType.values.map((v) => v.text).toList(),
          values: ActivityType.values,
          names: ctrl.typeIn,
          onDone: (typeIn) => ctrl.typeIn = typeIn,
          fixHeight: true,
        ),
      ),
    );
  }
}

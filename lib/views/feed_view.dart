import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/views/notifications_view.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/viewer_controller.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/activity_widgets.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/navigation/headline_header.dart';
import 'package:otraku/widgets/navigation/transparent_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';

class FeedView extends StatelessWidget {
  static const ROUTE = '/feed';

  final int id;
  FeedView(this.id);

  @override
  Widget build(BuildContext context) {
    final feed = Get.find<FeedController>(tag: id.toString());

    return Scaffold(
      appBar: CustomAppBar(title: 'Activities', trailing: [_Filter(feed)]),
      body: SafeArea(
        child: Obx(
          () {
            final activities = feed.activities;

            if (feed.isLoading) return const Center(child: Loader());

            if (activities.isEmpty)
              return Center(
                child: Text(
                  'No Activities',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              );

            return ListView.builder(
              physics: Config.PHYSICS,
              padding: Config.PADDING,
              controller: feed.scrollCtrl,
              itemBuilder: (_, i) =>
                  UserActivity(feed: feed, model: feed.activities[i]),
              itemCount: feed.activities.length,
            );
          },
        ),
      ),
    );
  }
}

class HomeFeedView extends StatelessWidget {
  const HomeFeedView();

  @override
  Widget build(BuildContext context) {
    final feed = Get.find<FeedController>(tag: FeedController.HOME_FEED_TAG);

    return CustomScrollView(
      controller: feed.scrollCtrl,
      physics: Config.PHYSICS,
      slivers: [
        const HeadlineHeader('Feed', false),
        _Header(feed),
        SliverRefreshControl(
          onRefresh: () => feed.fetchPage(clean: true),
          canRefresh: () => !feed.isLoading,
        ),
        SliverPadding(
          padding: Config.PADDING,
          sliver: Obx(
            () {
              final activities = feed.activities;

              if (feed.isLoading)
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
                  (_, i) => UserActivity(feed: feed, model: activities[i]),
                  childCount: activities.length,
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: NavBar.offset(context)),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final FeedController feed;
  _Header(this.feed);

  @override
  Widget build(BuildContext context) {
    final viewer = Get.find<ViewerController>();

    return TransparentHeader([
      BubbleTabs<bool>(
        options: ['Following', 'Global'],
        values: [true, false],
        initial: feed.onFollowing,
        onNewValue: (val) => feed.onFollowing = val,
        onSameValue: (_) => feed.scrollTo(0),
      ),
      const Spacer(),
      _Filter(feed),
      Tooltip(
        message: 'Notifications',
        child: GestureDetector(
          onTap: () => Get.toNamed(NotificationsView.ROUTE),
          child: Obx(
            () => Stack(
              children: [
                if (viewer.unreadCount > 0) ...[
                  Positioned(
                    right: 0,
                    child: const Icon(Ionicons.notifications_outline),
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
                      color: Theme.of(context).errorColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        viewer.unreadCount.toString(),
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: Theme.of(context).backgroundColor,
                            ),
                      ),
                    ),
                  ),
                ] else
                  const Icon(Ionicons.notifications_outline),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class _Filter extends StatelessWidget {
  final FeedController feed;
  _Filter(this.feed);

  @override
  Widget build(BuildContext context) {
    return ActionIcon(
      tooltip: 'Filter',
      icon: Ionicons.funnel_outline,
      onTap: () => Sheet.show(
        ctx: context,
        sheet: SelectionSheet<ActivityType>(
          options: ActivityType.values.map((v) => v.text).toList(),
          values: ActivityType.values,
          inclusive: feed.typeIn,
          onDone: (typeIn, _) => feed.typeIn = typeIn,
          fixHeight: true,
        ),
        isScrollControlled: true,
      ),
    );
  }
}

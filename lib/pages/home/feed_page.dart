import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/widgets/navigation/feed_control_header.dart';
import 'package:otraku/widgets/activity_widgets.dart';
import 'package:otraku/widgets/loader.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/navigation/headline_header.dart';
import 'package:otraku/widgets/refresh_control.dart';

class FeedPage extends StatelessWidget {
  const FeedPage();

  @override
  Widget build(BuildContext context) {
    final viewer = Get.find<Viewer>();
    return CustomScrollView(
      controller: viewer.scrollCtrl,
      physics: Config.PHYSICS,
      slivers: [
        const HeadlineHeader('Feed', false),
        FeedControlHeader(viewer),
        RefreshControl(
          onRefresh: viewer.fetch,
          canRefresh: () => !viewer.isLoading,
        ),
        SliverPadding(
          padding: Config.PADDING,
          sliver: Obx(
            () {
              final activities = viewer.activities;
              if (activities.isEmpty)
                return SliverFillRemaining(
                  child: Center(
                    child: viewer.isLoading
                        ? Loader()
                        : Text(
                            'No Activities',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                  ),
                );

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => UserActivity(activities[i]),
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

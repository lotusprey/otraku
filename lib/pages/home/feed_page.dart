import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/pages/notifications_page.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/activity_widgets.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/navigation/headline_header.dart';
import 'package:otraku/widgets/navigation/transparent_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';

class FeedTab extends StatelessWidget {
  const FeedTab();

  @override
  Widget build(BuildContext context) {
    final viewer = Get.find<Viewer>();
    return CustomScrollView(
      controller: viewer.scrollCtrl,
      physics: Config.PHYSICS,
      slivers: [
        const HeadlineHeader('Feed', false),
        _Header(viewer),
        SliverRefreshControl(
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

class _Header extends StatelessWidget {
  final Viewer viewer;
  _Header(this.viewer);

  @override
  Widget build(BuildContext context) => TransparentHeader([
        BubbleTabs<bool>(
          options: ['Following', 'Global'],
          values: [true, false],
          initial: viewer.onFollowing,
          onNewValue: (val) => viewer.updateFilters(following: val),
          onSameValue: (_) => viewer.scrollTo(0),
        ),
        const Spacer(),
        ActionIcon(
          tooltip: 'Filter',
          icon: Ionicons.funnel_outline,
          onTap: () => Sheet.show(
            ctx: context,
            sheet: SelectionSheet(
              options: ActivityType.values.map((v) => v.text).toList(),
              values: ActivityType.values,
              inclusive: viewer.typeIn,
              onDone: (typeIn, _) => viewer.updateFilters(
                types: typeIn as List<ActivityType>?,
              ),
              fixHeight: true,
            ),
            isScrollControlled: true,
          ),
        ),
        Tooltip(
          message: 'Notifications',
          child: GestureDetector(
            onTap: () => Get.toNamed(NotificationsPage.ROUTE),
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
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
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

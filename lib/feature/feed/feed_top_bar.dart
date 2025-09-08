import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/activity/activity_filter_sheet.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';

class FeedTopBarTrailingContent extends StatelessWidget {
  const FeedTopBarTrailingContent();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final count = ref.watch(
          settingsProvider.select(
            (s) => s.valueOrNull?.unreadNotifications ?? 0,
          ),
        );

        final openNotifications = ref.watch(viewerIdProvider) != null
            ? () {
                ref.read(settingsProvider.notifier).clearUnread();
                context.push(Routes.notifications);
              }
            : () => SnackBarExtension.show(
                  context,
                  'Log in to view notifications',
                );

        Widget notificationIcon = IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Ionicons.notifications_outline),
          onPressed: openNotifications,
        );

        if (count > 0) {
          notificationIcon = Badge.count(
            count: count,
            offset: Offset.zero,
            alignment: Alignment.topLeft,
            child: notificationIcon,
          );
        }

        return Row(
          children: [
            IconButton(
              tooltip: 'Forum',
              icon: const Icon(Ionicons.chatbubbles_outline),
              onPressed: () => context.push(Routes.forum),
            ),
            notificationIcon,
            IconButton(
              tooltip: 'Filter',
              icon: const Icon(Ionicons.funnel_outline),
              onPressed: () => showActivityFilterSheet(context, ref, HomeActivitiesTag.instance),
            ),
          ],
        );
      },
    );
  }
}

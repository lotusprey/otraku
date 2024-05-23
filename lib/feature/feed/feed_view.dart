import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/routing.dart';
import 'package:otraku/feature/activity/activity_filter_sheet.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activities_view.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class FeedSubview extends StatelessWidget {
  const FeedSubview(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final notificationIcon = Consumer(
      builder: (context, ref, child) {
        final count = ref.watch(
          settingsProvider.select(
            (s) => s.valueOrNull?.unreadNotifications ?? 0,
          ),
        );

        final openNotifications = () {
          ref.read(settingsProvider.notifier).clearUnread();
          context.push(Routes.notifications);
        };

        Widget result = TopBarIcon(
          tooltip: 'Notifications',
          icon: Ionicons.notifications_outline,
          onTap: openNotifications,
        );

        if (count > 0) {
          result = Badge.count(
            count: count,
            alignment: AlignmentDirectional.centerStart,
            child: result,
          );
        }

        return result;
      },
    );

    return Consumer(
      builder: (context, ref, _) {
        return TabScaffold(
          floatingBar: FloatingBar(
            scrollCtrl: scrollCtrl,
            children: [
              ActionButton(
                tooltip: 'New Post',
                icon: Icons.edit_outlined,
                onTap: () => showSheet(
                  context,
                  CompositionView(
                    tag: const StatusActivityCompositionTag(id: null),
                    onSaved: (map) => ref
                        .read(activitiesProvider(homeFeedId).notifier)
                        .insertActivity(map, Persistence().id!),
                  ),
                ),
              ),
            ],
          ),
          topBar: TopBar(
            canPop: false,
            title: 'Feed',
            trailing: [
              TopBarIcon(
                tooltip: 'Filter',
                icon: Ionicons.funnel_outline,
                onTap: () => showActivityFilterSheet(context, ref, homeFeedId),
              ),
              notificationIcon,
            ],
          ),
          child: ActivitiesSubView(homeFeedId, scrollCtrl),
        );
      },
    );
  }
}

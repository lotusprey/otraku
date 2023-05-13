import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/activity/activities_providers.dart';
import 'package:otraku/modules/activity/activities_view.dart';
import 'package:otraku/modules/composition/composition_model.dart';
import 'package:otraku/modules/composition/composition_view.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/common/utils/route_arg.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class FeedView extends StatelessWidget {
  const FeedView(this.scrollCtrl);

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
          Navigator.pushNamed(context, RouteArg.notifications);
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
                    composition: Composition.status(null, ''),
                    onDone: (map) => ref
                        .read(activitiesProvider(null).notifier)
                        .insertActivity(map, Options().id!),
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
                onTap: () => showActivityFilterSheet(context, ref, null),
              ),
              notificationIcon,
            ],
          ),
          child: ActivitiesSubView(null, scrollCtrl),
        );
      },
    );
  }
}

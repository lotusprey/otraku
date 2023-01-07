import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activities_view.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/composition/composition_model.dart';
import 'package:otraku/composition/composition_view.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

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

        if (count < 1) {
          return TopBarIcon(
            tooltip: 'Notifications',
            icon: Ionicons.notifications_outline,
            onTap: openNotifications,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Tooltip(
            message: 'Notifications',
            child: GestureDetector(
              onTap: openNotifications,
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
                        count.toString(),
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

    return Consumer(
      builder: (context, ref, _) {
        return PageLayout(
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
            items: [
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

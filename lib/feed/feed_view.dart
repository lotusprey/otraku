import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activities_view.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/composition/composition_model.dart';
import 'package:otraku/composition/composition_view.dart';
import 'package:otraku/feed/progress_tab.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class FeedView extends StatelessWidget {
  const FeedView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final notificationIcon = Consumer(
      builder: (context, ref, child) {
        final count = ref.watch(
          userSettingsProvider.select((s) => s.notificationCount),
        );

        final openNotifications = () {
          ref.read(userSettingsProvider.notifier).nullifyUnread();
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
        final notifier = ref.watch(homeProvider);

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
              ActionTabSwitcher(
                current: notifier.inboxOnFeed ? 1 : 0,
                onChanged: (i) => ref.read(homeProvider).inboxOnFeed = i == 1,
                items: const ['Progress', 'Feed'],
              ),
            ],
          ),
          topBar: TopBar(
            canPop: false,
            title: notifier.inboxOnFeed ? 'Feed' : 'Progress',
            items: [
              if (notifier.inboxOnFeed)
                TopBarIcon(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showActivityFilterSheet(context, ref, null),
                )
              else
                const SizedBox(width: 45),
              notificationIcon,
            ],
          ),
          child: DirectPageView(
            onChanged: null,
            current: notifier.inboxOnFeed ? 1 : 0,
            children: [
              ProgressTab(scrollCtrl),
              ActivitiesSubView(null, scrollCtrl),
            ],
          ),
        );
      },
    );
  }
}

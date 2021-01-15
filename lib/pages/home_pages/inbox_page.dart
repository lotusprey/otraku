import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/notifications.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/pages/pushable/notifications_page.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';
import 'package:otraku/tools/navigation/headline_header.dart';

class InboxPage extends StatelessWidget {
  const InboxPage();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Viewer>(
      builder: (viewer) => CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          HeadlineHeader('Feed', false),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BubbleTabs(
                  options: ['Following', 'Global'],
                  values: [false, true],
                  initial: false,
                  onNewValue: (_) {},
                  onSameValue: (_) {},
                ),
                IconButton(
                  icon: Icon(Icons.notifications_outlined),
                  onPressed: () => Get.to(
                    NotificationsPage(),
                    binding: BindingsBuilder.put(
                      () => Notifications()..fetchData(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

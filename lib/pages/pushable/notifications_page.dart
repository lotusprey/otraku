import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/notifications.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/models/anilist/notification_model.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';
import 'package:otraku/tools/overlays/option_sheet.dart';

class NotificationsPage extends StatelessWidget {
  static const ROUTE = '/notifications';

  @override
  Widget build(BuildContext context) {
    final notifications = Get.find<Notifications>();
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        trailing: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => OptionSheet(
                title: 'Category',
                options: ['All', 'Activities', 'Forum', 'Media', 'Follows'],
                index: notifications.filter,
                onTap: (val) => notifications.filter = val,
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
      body: GetBuilder<Notifications>(builder: (notifications) {
        final entries = notifications.entries;
        if (entries == null) return const SizedBox();
        return ListView.builder(
          padding: Config.PADDING,
          physics: Config.PHYSICS,
          controller: notifications.scrollCtrl,
          itemBuilder: (_, index) {
            if (index == entries.length - 5) notifications.fetchPage();
            return _NotificationWidget(
              entries[index],
              index < notifications.unreadCount,
            );
          },
          itemCount: entries.length,
          itemExtent: 100,
        );
      }),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  final NotificationModel notification;
  final bool unread;

  _NotificationWidget(this.notification, this.unread);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => BrowseIndexer.openPage(
                id: notification.headId,
                imageUrl: notification.imageUrl,
                browsable: notification.browsable ?? Browsable.user,
              ),
              onLongPress: () {
                if (notification.browsable == Browsable.anime ||
                    notification.browsable == Browsable.manga)
                  BrowseIndexer.openEditPage(notification.headId);
              },
              child: ClipRRect(
                child: FadeImage(notification.imageUrl, width: 70),
                borderRadius: BorderRadius.horizontal(left: Config.RADIUS),
              ),
            ),
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (notification.browsable != null)
                    BrowseIndexer.openPage(
                      id: notification.bodyId,
                      imageUrl: notification.imageUrl,
                      browsable: notification.browsable,
                    );
                },
                onLongPress: () {
                  if (notification.browsable == Browsable.anime ||
                      notification.browsable == Browsable.manga)
                    BrowseIndexer.openEditPage(notification.headId);
                },
                child: Padding(
                  padding: Config.PADDING,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        overflow: TextOverflow.fade,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyText1,
                          children: [
                            for (int i = 0; i < notification.texts.length; i++)
                              TextSpan(
                                text: notification.texts[i],
                                style: (i % 2 == 0) ==
                                        notification.markTextOnEvenIndex
                                    ? Theme.of(context).textTheme.bodyText2
                                    : null,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        notification.timestamp,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (unread)
              Container(
                width: 10,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.horizontal(right: Config.RADIUS),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

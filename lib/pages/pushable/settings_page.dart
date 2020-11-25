import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/pages/pushable/setting_fragments/app_settings_page.dart';
import 'package:otraku/pages/pushable/setting_fragments/list_settings_page.dart';
import 'package:otraku/pages/pushable/setting_fragments/media_settings_page.dart';
import 'package:otraku/pages/pushable/setting_fragments/notification_settings_page.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/controllers/users.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  static const padding = const EdgeInsets.symmetric(horizontal: 5);

  final Map<String, dynamic> changes = {};

  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: 'Settings',
          callOnPop: () {
            if (changes.keys.length > 0) {
              Get.find<Users>().updateSettings(changes).then((_) {
                if (changes.containsKey('displayAdultContent')) {
                  if (changes['displayAdultContent']) {
                    Get.find<Explorable>()
                        .setFilterWithKey(Explorable.IS_ADULT);
                  } else {
                    Get.find<Explorable>()
                        .setFilterWithKey(Explorable.IS_ADULT, value: false);
                  }
                }
                if (changes.containsKey('scoreFormat') ||
                    changes.containsKey('titleLanguage')) {
                  Get.find<Collections>().fetchMyAnime();
                  Get.find<Collections>().fetchMyManga();
                  return;
                }
                if (changes.containsKey('splitCompletedAnime')) {
                  Get.find<Collections>().fetchMyAnime();
                }
                if (changes.containsKey('splitCompletedManga')) {
                  Get.find<Collections>().fetchMyManga();
                }
              });
            }
          },
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          children: [
            ListTile(
              contentPadding: padding,
              leading: Icon(
                FluentSystemIcons.ic_fluent_phone_link_setup_regular,
                color: Theme.of(context).dividerColor,
              ),
              title: Text('App', style: Theme.of(context).textTheme.bodyText1),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (ctx) => AppSettingsPage(),
                  )),
            ),
            ListTile(
              contentPadding: padding,
              leading: Icon(
                Icons.video_settings,
                color: Theme.of(context).dividerColor,
              ),
              title:
                  Text('Media', style: Theme.of(context).textTheme.bodyText1),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (ctx) => MediaSettingsPage(changes),
                  )),
            ),
            ListTile(
              contentPadding: padding,
              leading: Icon(
                Icons.filter_list,
                color: Theme.of(context).dividerColor,
              ),
              title:
                  Text('Lists', style: Theme.of(context).textTheme.bodyText1),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (ctx) => ListSettingsPage(changes),
                  )),
            ),
            ListTile(
              contentPadding: padding,
              leading: Icon(
                Icons.notifications_none,
                color: Theme.of(context).dividerColor,
              ),
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (ctx) => NotificationSettingsPage(changes),
                  )),
            ),
          ],
        ),
      );
}

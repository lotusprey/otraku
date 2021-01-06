import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/services/filterable.dart';
import 'package:otraku/controllers/user_settings.dart';
import 'package:otraku/pages/setting_pages/app_settings_page.dart';
import 'package:otraku/pages/setting_pages/list_settings_page.dart';
import 'package:otraku/pages/setting_pages/media_settings_page.dart';
import 'package:otraku/pages/setting_pages/notification_settings_page.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';

class SettingsPage extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 5);

  final Map<String, dynamic> changes = {};

  Widget build(BuildContext context) {
    final tabs = [
      AppSettingsPage(),
      MediaSettingsPage(changes),
      ListSettingsPage(changes),
      NotificationSettingsPage(changes),
    ];

    return GetBuilder<UserSettings>(
      builder: (userSettings) => Scaffold(
        extendBody: true,
        bottomNavigationBar: CustomNavBar(
          icons: const [
            FluentSystemIcons.ic_fluent_phone_link_setup_regular,
            Icons.video_settings,
            Icons.filter_list,
            Icons.notifications_none,
          ],
          onChanged: (page) => userSettings.page = page,
          initial: userSettings.page,
        ),
        appBar: CustomAppBar(
          title: userSettings.pageName,
          callOnPop: () {
            if (changes.keys.length > 0) {
              Get.find<UserSettings>().updateSettings(changes).then((_) {
                if (changes.containsKey('displayAdultContent')) {
                  if (changes['displayAdultContent']) {
                    Get.find<Explorer>().setFilterWithKey(Filterable.IS_ADULT);
                  } else {
                    Get.find<Explorer>()
                        .setFilterWithKey(Filterable.IS_ADULT, value: false);
                  }
                }
                if (changes.containsKey('scoreFormat') ||
                    changes.containsKey('titleLanguage')) {
                  Get.find<Collection>(tag: Collection.ANIME).fetch();
                  Get.find<Collection>(tag: Collection.MANGA).fetch();
                  return;
                }
                if (changes.containsKey('splitCompletedAnime')) {
                  Get.find<Collection>(tag: Collection.ANIME).fetch();
                }
                if (changes.containsKey('splitCompletedManga')) {
                  Get.find<Collection>(tag: Collection.MANGA).fetch();
                }
              });
            }
          },
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: tabs[userSettings.page],
        ),
      ),
    );
  }
}

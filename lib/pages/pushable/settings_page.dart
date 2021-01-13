import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/pages/setting_pages/app_settings_page.dart';
import 'package:otraku/pages/setting_pages/list_settings_page.dart';
import 'package:otraku/pages/setting_pages/media_settings_page.dart';
import 'package:otraku/pages/setting_pages/notification_settings_page.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';

class SettingsPage extends StatelessWidget {
  static const _pageNames = {
    0: 'App Settings',
    1: 'Media Settings',
    2: 'List Settings',
    3: 'Notification Settings',
  };

  Widget build(BuildContext context) {
    final tabs = [
      AppSettingsPage(),
      MediaSettingsPage(),
      ListSettingsPage(),
      NotificationSettingsPage(),
    ];

    return GetBuilder<Settings>(
      builder: (settings) => Scaffold(
        extendBody: true,
        bottomNavigationBar: CustomNavBar(
          icons: const [
            FluentSystemIcons.ic_fluent_phone_link_setup_regular,
            Icons.video_settings,
            Icons.filter_list,
            Icons.notifications_none,
          ],
          onChanged: (page) => settings.pageIndex = page,
          initial: settings.pageIndex,
        ),
        appBar: CustomAppBar(title: _pageNames[settings.pageIndex]),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: tabs[settings.pageIndex],
        ),
      ),
    );
  }
}

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/pages/settings/app_settings_tab.dart';
import 'package:otraku/pages/settings/content_settings_tab.dart';
import 'package:otraku/pages/settings/notification_settings_tab.dart';
import 'package:otraku/pages/settings/profile_settings_tab.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';

class SettingsPage extends StatelessWidget {
  static const _pageNames = {
    0: 'App Settings',
    1: 'Content Settings',
    2: 'Notification Settings',
    3: 'Profile Settings',
  };

  Widget build(BuildContext context) {
    final tabs = [
      AppSettingsTab(),
      ContentSettingsTab(),
      NotificationSettingsTab(),
      ProfileSettingsTab(),
    ];

    return GetBuilder<Settings>(
      builder: (settings) => Scaffold(
        extendBody: true,
        bottomNavigationBar: CustomNavBar(
          icons: const [
            FluentSystemIcons.ic_fluent_phone_link_setup_regular,
            Icons.video_settings,
            Icons.notifications_none,
            Icons.account_circle_outlined,
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

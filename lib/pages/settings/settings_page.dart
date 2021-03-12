import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/pages/settings/app_settings_tab.dart';
import 'package:otraku/pages/settings/content_settings_tab.dart';
import 'package:otraku/pages/settings/notification_settings_tab.dart';
import 'package:otraku/pages/settings/profile_settings_tab.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsPage extends StatelessWidget {
  static const ROUTE = '/settings';

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
        bottomNavigationBar: NavBar(
          options: {
            FluentIcons.phone_link_setup_24_regular: 'App',
            Icons.video_settings: 'Content',
            Icons.notifications_none: 'Notifications',
            Icons.account_circle_outlined: 'Profile',
          },
          onChanged: (page) => settings.pageIndex = page,
          initial: settings.pageIndex,
        ),
        appBar: CustomAppBar(title: _pageNames[settings.pageIndex]),
        body: AnimatedSwitcher(
          duration: Config.TAB_SWITCH_DURATION,
          child: tabs[settings.pageIndex],
        ),
      ),
    );
  }
}

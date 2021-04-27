import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/pages/settings/app_settings_tab.dart';
import 'package:otraku/pages/settings/content_settings_tab.dart';
import 'package:otraku/pages/settings/notification_settings_tab.dart';
import 'package:otraku/pages/settings/about_tab.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsPage extends StatelessWidget {
  static const ROUTE = '/settings';

  static const _pageNames = {
    0: 'App Settings',
    1: 'Content Settings',
    2: 'Notification Settings',
    3: 'About',
  };

  Widget build(BuildContext context) {
    final tabs = [
      AppSettingsTab(),
      ContentSettingsTab(),
      NotificationSettingsTab(),
      AboutTab(),
    ];

    return GetBuilder<Settings>(
      builder: (settings) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: {
            'App': FluentIcons.phone_link_setup_24_regular,
            'Content': Icons.video_settings,
            'Notifications': Icons.notifications_none,
            'Profile': Icons.account_circle_outlined,
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

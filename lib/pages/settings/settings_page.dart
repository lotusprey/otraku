import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/pages/settings/personalisation_page.dart';
import 'package:otraku/pages/settings/content_page.dart';
import 'package:otraku/pages/settings/notification_settings_page.dart';
import 'package:otraku/pages/settings/about_page.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsPage extends StatelessWidget {
  static const ROUTE = '/settings';

  static const _pageNames = {
    0: 'Personalisation',
    1: 'Content',
    2: 'Notifications',
    3: 'About',
  };

  Widget build(BuildContext context) {
    final tabs = [
      PersonalisationTab(),
      ContentTab(),
      NotificationSettingsTab(),
      AboutTab(),
    ];

    return GetBuilder<Settings>(
      builder: (settings) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: {
            'Personalisation': Icons.palette_outlined,
            'Content': Icons.video_settings,
            'Notifications': Icons.notifications_none,
            'About': Icons.account_circle_outlined,
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

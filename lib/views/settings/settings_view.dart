import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings_controller.dart';
import 'package:otraku/views/settings/personalisation_tab.dart';
import 'package:otraku/views/settings/content_tab.dart';
import 'package:otraku/views/settings/notification_settings_tab.dart';
import 'package:otraku/views/settings/about_tab.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsView extends StatelessWidget {
  static const ROUTE = '/settings';

  Widget build(BuildContext context) {
    const pageNames = {
      0: 'Personalisation',
      1: 'Content',
      2: 'Notifications',
      3: 'About',
    };

    const tabs = [
      PersonalisationTab(),
      ContentTab(),
      NotificationSettingsTab(),
      AboutTab(),
    ];

    return GetBuilder<SettingsController>(
      builder: (settings) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: const {
            'Personalisation': Ionicons.color_palette_outline,
            'Content': Ionicons.tv_outline,
            'Notifications': Ionicons.notifications_outline,
            'About': Ionicons.person_circle_outline,
          },
          onChanged: (page) => settings.pageIndex = page,
          initial: settings.pageIndex,
        ),
        appBar: CustomAppBar(title: pageNames[settings.pageIndex]),
        body: AnimatedSwitcher(
          duration: Config.TAB_SWITCH_DURATION,
          child: tabs[settings.pageIndex],
        ),
      ),
    );
  }
}

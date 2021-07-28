import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings_controller.dart';
import 'package:otraku/views/settings_app_view.dart';
import 'package:otraku/views/settings_content_view.dart';
import 'package:otraku/views/settings_notifications_view.dart';
import 'package:otraku/views/settings_about_view.dart';
import 'package:otraku/widgets/navigation/shadow_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsView extends StatelessWidget {
  Widget build(BuildContext context) {
    const _pageNames = ['App', 'Content', 'Notifications', 'About'];

    const _tabs = [
      SettingsAppView(),
      SettingsContentView(),
      SettingsNotificationsView(),
      SettingsAboutView(),
    ];

    return GetBuilder<SettingsController>(
      builder: (settings) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: const {
            'App': Ionicons.color_palette_outline,
            'Content': Ionicons.tv_outline,
            'Notifications': Ionicons.notifications_outline,
            'About': Ionicons.person_circle_outline,
          },
          onChanged: (page) => settings.pageIndex = page,
          initial: settings.pageIndex,
        ),
        appBar: ShadowAppBar(title: _pageNames[settings.pageIndex]),
        body: AnimatedSwitcher(
          duration: Config.TAB_SWITCH_DURATION,
          child: _tabs[settings.pageIndex],
        ),
      ),
    );
  }
}

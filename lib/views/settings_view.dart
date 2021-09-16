import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/settings_controller.dart';
import 'package:otraku/views/settings_app_view.dart';
import 'package:otraku/views/settings_content_view.dart';
import 'package:otraku/views/settings_notifications_view.dart';
import 'package:otraku/views/settings_about_view.dart';
import 'package:otraku/widgets/nav_scaffold.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

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
      builder: (settings) => NavScaffold(
        setPage: (page) => settings.pageIndex = page,
        index: settings.pageIndex,
        items: const {
          'App': Ionicons.color_palette_outline,
          'Content': Ionicons.tv_outline,
          'Notifications': Ionicons.notifications_outline,
          'About': Ionicons.information_outline,
        },
        appBar: ShadowAppBar(title: _pageNames[settings.pageIndex]),
        child: _tabs[settings.pageIndex],
      ),
    );
  }
}

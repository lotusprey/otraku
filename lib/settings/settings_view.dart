import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/settings/settings_app_tab.dart';
import 'package:otraku/settings/settings_content_tab.dart';
import 'package:otraku/settings/settings_notifications_tab.dart';
import 'package:otraku/settings/settings_about_tab.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/tab_switcher.dart';

class SettingsView extends StatefulWidget {
  const SettingsView();

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _ctrl = ScrollController();
  bool _shouldUpdate = false;
  int _tabIndex = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    const pageNames = ['App', 'Content', 'Notifications', 'About'];

    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(userSettingsProvider).copy();

        ref.listen<UserSettings>(userSettingsProvider, (prev, next) {
          if (prev?.scoreFormat != next.scoreFormat ||
              prev?.titleLanguage != next.titleLanguage) {
            Get.find<CollectionController>(
              tag: '${Settings().id}true',
            ).refetch();
            Get.find<CollectionController>(
              tag: '${Settings().id}false',
            ).refetch();
          } else if (prev?.splitCompletedAnime != next.splitCompletedAnime) {
            Get.find<CollectionController>(
              tag: '${Settings().id}true',
            ).refetch();
          } else if (prev?.splitCompletedManga != next.splitCompletedManga) {
            Get.find<CollectionController>(
              tag: '${Settings().id}false',
            ).refetch();
          }
        });

        final tabs = [
          SettingsAppTab(_ctrl),
          SettingsContentTab(_ctrl, settings, () => _shouldUpdate = true),
          SettingsNotificationsTab(
            _ctrl,
            settings,
            () => _shouldUpdate = true,
          ),
          SettingsAboutTab(_ctrl),
        ];

        return WillPopScope(
          onWillPop: () {
            if (_shouldUpdate)
              ref.read(userSettingsProvider.notifier).update(settings);
            return Future.value(true);
          },
          child: PageLayout(
            topBar: TopBar(title: pageNames[_tabIndex]),
            bottomBar: BottomBarIconTabs(
              index: _tabIndex,
              onSame: (_) => _ctrl.scrollUpTo(0),
              onChanged: (i) => setState(() => _tabIndex = i),
              items: const {
                'App': Ionicons.color_palette_outline,
                'Content': Ionicons.tv_outline,
                'Notifications': Ionicons.notifications_outline,
                'About': Ionicons.information_outline,
              },
            ),
            builder: (context, _, __) => TabSwitcher(
              tabs: tabs,
              index: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
          ),
        );
      },
    );
  }
}

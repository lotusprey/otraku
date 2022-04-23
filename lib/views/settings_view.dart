import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/providers/user_settings.dart';
import 'package:otraku/utils/scrolling_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/settings_app_view.dart';
import 'package:otraku/views/settings_content_view.dart';
import 'package:otraku/views/settings_notifications_view.dart';
import 'package:otraku/views/settings_about_view.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class SettingsView extends StatefulWidget {
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

    // TODO test
    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(userSettingsProvider);

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

        return WillPopScope(
          onWillPop: () {
            if (_shouldUpdate)
              ref.read(userSettingsProvider.notifier).update(settings);
            return Future.value(true);
          },
          child: NavLayout(
            navRow: NavIconRow(
              index: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
              onSame: (_) => _ctrl.scrollUpTo(0),
              items: const {
                'App': Ionicons.color_palette_outline,
                'Content': Ionicons.tv_outline,
                'Notifications': Ionicons.notifications_outline,
                'About': Ionicons.information_outline,
              },
            ),
            appBar: ShadowAppBar(title: pageNames[_tabIndex]),
            child: _buildTab(settings),
          ),
        );
      },
    );
  }

  Widget _buildTab(UserSettings settings) {
    switch (_tabIndex) {
      case 0:
        return SettingsAppView(_ctrl);
      case 1:
        return SettingsContentView(
          _ctrl,
          settings,
          () => _shouldUpdate = true,
        );
      case 2:
        return SettingsNotificationsView(
          _ctrl,
          settings,
          () => _shouldUpdate = true,
        );
      default:
        return SettingsAboutView(_ctrl);
    }
  }
}

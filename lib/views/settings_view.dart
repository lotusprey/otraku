import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
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
  final _changes = <String, dynamic>{};
  final _ctrl = ScrollController();
  int _tabIndex = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    const _pageNames = ['App', 'Content', 'Notifications', 'About'];

    List<Widget>? _tabs;

    return GetBuilder<HomeController>(
      id: HomeController.ID_SETTINGS,
      dispose: (state) async {
        if (_changes.isNotEmpty &&
            state.controller != null &&
            await state.controller!.updateSettings(_changes)) {
          if (_changes.containsKey('scoreFormat') ||
              _changes.containsKey('titleLanguage')) {
            Get.find<CollectionController>(
              tag: '${Settings().id}true',
            ).refetch();
            Get.find<CollectionController>(
              tag: '${Settings().id}false',
            ).refetch();
          } else {
            if (_changes.containsKey('splitCompletedAnime'))
              Get.find<CollectionController>(
                tag: '${Settings().id}true',
              ).refetch();

            if (_changes.containsKey('splitCompletedManga'))
              Get.find<CollectionController>(
                tag: '${Settings().id}false',
              ).refetch();
          }
        }
      },
      builder: (ctrl) {
        if (_tabs == null)
          _tabs = [
            SettingsAppView(_ctrl),
            SettingsContentView(ctrl.siteSettings!, _changes, _ctrl),
            SettingsNotificationsView(ctrl.siteSettings!, _changes, _ctrl),
            SettingsAboutView(_ctrl),
          ];

        return NavLayout(
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
          appBar: ShadowAppBar(title: _pageNames[_tabIndex]),
          child: _tabs![_tabIndex],
        );
      },
    );
  }
}

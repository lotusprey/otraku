import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/views/settings_app_view.dart';
import 'package:otraku/views/settings_content_view.dart';
import 'package:otraku/views/settings_notifications_view.dart';
import 'package:otraku/views/settings_about_view.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class SettingsView extends StatelessWidget {
  final changes = <String, dynamic>{};

  Widget build(BuildContext context) {
    const _pageNames = ['App', 'Content', 'Notifications', 'About'];

    List<Widget>? _tabs;

    return GetBuilder<HomeController>(
      id: HomeController.ID_SETTINGS,
      dispose: (state) async {
        if (changes.isNotEmpty &&
            state.controller != null &&
            await state.controller!.updateSettings(changes)) {
          if (changes.containsKey('displayAdultContent')) {
            if (changes['displayAdultContent'])
              Get.find<ExploreController>()
                  .setFilterWithKey(Filterable.IS_ADULT);
            else
              Get.find<ExploreController>()
                  .setFilterWithKey(Filterable.IS_ADULT, value: false);
          }

          if (changes.containsKey('scoreFormat') ||
              changes.containsKey('titleLanguage')) {
            Get.find<CollectionController>(
              tag: '${LocalSettings().id}true',
            ).refetch();
            Get.find<CollectionController>(
              tag: '${LocalSettings().id}false',
            ).refetch();
          } else {
            if (changes.containsKey('splitCompletedAnime'))
              Get.find<CollectionController>(
                tag: '${LocalSettings().id}true',
              ).refetch();

            if (changes.containsKey('splitCompletedManga'))
              Get.find<CollectionController>(
                tag: '${LocalSettings().id}false',
              ).refetch();
          }
        }
      },
      builder: (ctrl) {
        if (_tabs == null)
          _tabs = [
            const SettingsAppView(),
            SettingsContentView(ctrl.siteSettings!, changes),
            SettingsNotificationsView(ctrl.siteSettings!, changes),
            const SettingsAboutView(),
          ];

        return NavLayout(
          index: ctrl.settingsTab,
          onChanged: (i) => ctrl.settingsTab = i,
          onSame: (_) => ctrl.scrollUpTo(0),
          items: const {
            'App': Ionicons.color_palette_outline,
            'Content': Ionicons.tv_outline,
            'Notifications': Ionicons.notifications_outline,
            'About': Ionicons.information_outline,
          },
          appBar: ShadowAppBar(title: _pageNames[ctrl.settingsTab]),
          child: _tabs![ctrl.settingsTab],
        );
      },
    );
  }
}

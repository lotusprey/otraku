import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/switch_tile.dart';

class MediaSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<Settings>();
    return ListView(
      physics: Config.PHYSICS,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: [
        DropDownField(
          title: 'Title Language',
          initialValue: settings.data.titleLanguage,
          items: {
            'Romaji': 'ROMAJI',
            'English': 'ENGLISH',
            'Native': 'NATIVE',
          },
          onChanged: (value) {
            const key = 'titleLanguage';
            if (value == Get.find<Viewer>().settings.titleLanguage) {
              settings.changes.remove(key);
            } else {
              settings.changes[key] = value;
            }
          },
        ),
        SwitchTile(
          title: 'Airing Anime Notifications',
          initialValue: Get.find<Viewer>().settings.airingNotifications,
          onChanged: (value) {
            const notifications = 'airingNotifications';
            if (settings.changes.containsKey(notifications)) {
              settings.changes.remove(notifications);
            } else {
              settings.changes[notifications] = value;
            }
          },
        ),
        SwitchTile(
          title: '18+ Content',
          initialValue: Get.find<Viewer>().settings.displayAdultContent,
          onChanged: (value) {
            const adultContent = 'displayAdultContent';
            if (settings.changes.containsKey(adultContent)) {
              settings.changes.remove(adultContent);
            } else {
              settings.changes[adultContent] = value;
            }
          },
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

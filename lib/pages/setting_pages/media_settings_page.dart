import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/controllers/user_settings.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/switch_tile.dart';

class MediaSettingsPage extends StatelessWidget {
  final Map<String, dynamic> changes;

  MediaSettingsPage(this.changes);

  @override
  Widget build(BuildContext context) => ListView(
        physics: Config.PHYSICS,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: [
          DropDownField(
            title: 'Title Language',
            initialValue: Get.find<UserSettings>().settings.titleLanguage,
            items: {
              'Romaji': 'ROMAJI',
              'English': 'ENGLISH',
              'Native': 'NATIVE',
            },
            onChanged: (value) {
              const key = 'titleLanguage';
              if (value == Get.find<UserSettings>().settings.titleLanguage) {
                changes.remove(key);
              } else {
                changes[key] = value;
              }
            },
          ),
          SwitchTile(
            title: 'Airing Anime Notifications',
            initialValue: Get.find<UserSettings>().settings.airingNotifications,
            onChanged: (value) {
              const notifications = 'airingNotifications';
              if (changes.containsKey(notifications)) {
                changes.remove(notifications);
              } else {
                changes[notifications] = value;
              }
            },
          ),
          SwitchTile(
            title: '18+ Content',
            initialValue: Get.find<UserSettings>().settings.displayAdultContent,
            onChanged: (value) {
              const adultContent = 'displayAdultContent';
              if (changes.containsKey(adultContent)) {
                changes.remove(adultContent);
              } else {
                changes[adultContent] = value;
              }
            },
          ),
          const SizedBox(height: 50),
        ],
      );
}

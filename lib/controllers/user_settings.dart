import 'package:get/get.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/models/settings.dart';

class UserSettings extends GetxController {
  static const _settingsQuery = r'''
    query {
      Viewer {
        options {
          titleLanguage 
          displayAdultContent
          airingNotifications
          notificationOptions {type enabled}
        }
        mediaListOptions {
          scoreFormat
          rowOrder
          animeList {splitCompletedSectionByFormat customLists}
          mangaList {splitCompletedSectionByFormat customLists}
        }
      }
    }''';

  static const _settingsMutation = r'''
    mutation UpdateUser($about: String, $titleLanguage: UserTitleLanguage, 
        $displayAdultContent: Boolean, $airingNotifications: Boolean, $scoreFormat: ScoreFormat, $rowOrder: String, 
        $notificationOptions: [NotificationOptionInput], $splitCompletedAnime: Boolean, 
        $splitCompletedManga: Boolean,) {
      UpdateUser(about: $about, titleLanguage: $titleLanguage, 
          displayAdultContent: $displayAdultContent, airingNotifications: $airingNotifications,
          scoreFormat: $scoreFormat, rowOrder: $rowOrder, notificationOptions: $notificationOptions,
          animeListOptions: {splitCompletedSectionByFormat: $splitCompletedAnime},
          mangaListOptions: {splitCompletedSectionByFormat: $splitCompletedManga}) {
        options {
          titleLanguage 
          displayAdultContent
          airingNotifications
          notificationOptions {type enabled}
        }
        mediaListOptions {
          scoreFormat
          rowOrder
          animeList {splitCompletedSectionByFormat}
          mangaList {splitCompletedSectionByFormat}
        }
      }
    }
  ''';

  Settings _settings;

  Settings get settings => _settings;

  Future<void> fetchSettings() async {
    final data =
        await NetworkService.request(_settingsQuery, null, popOnError: false);

    if (data == null) return;

    _settings = Settings(data['Viewer']);
    update();
  }

  Future<Settings> updateSettings(Map<String, dynamic> variables) async {
    final data = await NetworkService.request(_settingsMutation, variables);

    if (data == null) return null;

    _settings = Settings(data['UpdateUser']);

    return _settings;
  }
}

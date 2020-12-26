import 'package:get/get.dart';
import 'package:otraku/services/graph_ql.dart';
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
  int _page = 0;

  Settings get settings => _settings;

  int get page => _page;

  set page(int val) {
    _page = val;
    update();
  }

  String get pageName {
    if (_page < 1) return 'App Settings';
    if (_page < 2) return 'Media Settings';
    if (_page < 3) return 'List Settings';
    return 'Notification Settings';
  }

  Future<void> fetchSettings() async {
    final data = await GraphQl.request(_settingsQuery, null, popOnError: false);

    if (data == null) return;

    _settings = Settings(data['Viewer']);
    update();
  }

  Future<Settings> updateSettings(Map<String, dynamic> variables) async {
    final data = await GraphQl.request(_settingsMutation, variables);

    if (data == null) return null;

    _settings = Settings(data['UpdateUser']);

    return _settings;
  }
}

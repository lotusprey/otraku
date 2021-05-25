import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/models/settings_model.dart';

class Viewer extends GetxController {
  static const _viewerQuery = r'''
    query ViewerData {
      Viewer {
        unreadNotificationCount
        options {
          titleLanguage 
          activityMergeTime
          displayAdultContent
          airingNotifications
          notificationOptions {type enabled}
        }
        mediaListOptions {
          scoreFormat
          rowOrder
          animeList {splitCompletedSectionByFormat customLists advancedScoringEnabled}
          mangaList {splitCompletedSectionByFormat customLists}
        }
    }
  }
  ''';

  static const _settingsMutation = r'''
    mutation UpdateSettings($about: String, $titleLanguage: UserTitleLanguage, $activityMergeTime: Int, 
        $displayAdultContent: Boolean, $airingNotifications: Boolean, $scoreFormat: ScoreFormat, $rowOrder: String, 
        $notificationOptions: [NotificationOptionInput], $splitCompletedAnime: Boolean, 
        $splitCompletedManga: Boolean, $advancedScoringEnabled: Boolean) {
      UpdateUser(about: $about, titleLanguage: $titleLanguage, activityMergeTime: $activityMergeTime, 
          displayAdultContent: $displayAdultContent, airingNotifications: $airingNotifications,
          scoreFormat: $scoreFormat, rowOrder: $rowOrder, notificationOptions: $notificationOptions,
          animeListOptions: {splitCompletedSectionByFormat: $splitCompletedAnime, advancedScoringEnabled: $advancedScoringEnabled},
          mangaListOptions: {splitCompletedSectionByFormat: $splitCompletedManga, advancedScoringEnabled: $advancedScoringEnabled}) {
        options {
          titleLanguage
          activityMergeTime
          displayAdultContent
          airingNotifications
          notificationOptions {type enabled}
        }
        mediaListOptions {
          scoreFormat
          rowOrder
          animeList {splitCompletedSectionByFormat advancedScoringEnabled}
          mangaList {splitCompletedSectionByFormat}
        }
      }
    }
  ''';

  final _unreadCount = 0.obs;
  SettingsModel? _settings;

  SettingsModel? get settings => _settings;
  int get unreadCount => _unreadCount();

  void nullifyUnread() {
    _unreadCount.value = 0;
    Config.storage.write(Config.LAST_NOTIFICATION_COUNT, 0);
  }

  Future<void> fetch() async {
    final data = await Client.request(_viewerQuery, {}, popOnErr: false);
    if (data == null) return;

    if (_settings == null) _settings = SettingsModel(data['Viewer']);
    _unreadCount.value = data['Viewer']['unreadNotificationCount'] ?? 0;
    Config.storage.write(Config.LAST_NOTIFICATION_COUNT, _unreadCount());
    update();
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data =
        await Client.request(_settingsMutation, variables, popOnErr: false);
    if (data == null) return false;
    _settings = SettingsModel(data['UpdateUser']);
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}

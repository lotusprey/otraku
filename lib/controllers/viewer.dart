import 'package:get/get.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/models/anilist/settings_data.dart';

class Viewer extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _viewerQuery = r'''
    query ViewerData($withMain: Boolean = false, $page: Int = 1, $isFollowing: Boolean = false) {
      Viewer {unreadNotificationCount ...main @include(if: $withMain)}
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(isFollowing: $isFollowing) {...activity}
      }
    }
    fragment main on User {
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
    fragment activity on ActivityUnion {
      ... on TextActivity {
        type
        replyCount
        text(asHtml: true)
        likeCount
        isLiked
        user {id name avatar {large}}
        createdAt
      }
    }
  ''';

  static const _settingsMutation = r'''
    mutation UpdateSettings($about: String, $titleLanguage: UserTitleLanguage, 
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

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final _unreadCount = 0.obs;
  SettingsData _settings;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  int get unreadCount => _unreadCount();

  SettingsData get settings => _settings;

  void nullifyUnread() => _unreadCount.value = 0;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchData() async {
    final data = await Network.request(
      _viewerQuery,
      {'withMain': true, 'withActivities': true},
      popOnErr: false,
    );
    if (data == null) return;

    _settings = SettingsData(data['Viewer']);
    _unreadCount.value = data['Viewer']['unreadNotificationCount'];
    update();
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data = await Network.request(_settingsMutation, variables);
    if (data == null) return false;
    _settings = SettingsData(data['UpdateUser']);
    return true;
  }
}

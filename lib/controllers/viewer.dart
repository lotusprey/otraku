import 'package:get/get.dart';
import 'package:otraku/models/anilist/notification_data.dart';
import 'package:otraku/services/network.dart';
import 'package:otraku/models/anilist/settings_data.dart';

class Viewer extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _viewerQuery = r'''
    query ViewerData($withMain: Boolean = false, $page: Int = 1, $type_in: [NotificationType]) {
      Viewer {
        unreadNotificationCount
        ...main @include(if: $withMain)
      }
      Page(page: $page) {
        notifications(type_in: $type_in) {
          ... on FollowingNotification {
            type
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMessageNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplySubscribedNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentReplyNotification {
            type
            context
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMentionNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentMentionNotification {
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentSubscribedNotification {
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityLikeNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyLikeNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadLikeNotification {
            type
            thread {id title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentLikeNotification {
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on AiringNotification {
            type
            episode
            media {id type bannerImage title {userPreferred} coverImage {large}}
            createdAt
          }
          ... on RelatedMediaAdditionNotification {
            type
            media {id type bannerImage title {userPreferred} coverImage {large}}
            createdAt
          }
        }
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

  List<NotificationData> _notifications = [];
  SettingsData _settings;

  // ***************************************************************************
  // GETTERS
  // ***************************************************************************

  List<NotificationData> get notifications => _notifications;

  SettingsData get settings => _settings;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchData() async {
    final data = await Network.request(_viewerQuery, {'withMain': true},
        popOnErr: false);
    if (data == null) return;

    _settings = SettingsData(data['Viewer']);

    for (final notification in data['Page']['notifications']) {
      final n = NotificationData(notification);
      if (n != null) _notifications.add(n);
    }

    update();
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data = await Network.request(_settingsMutation, variables);
    if (data == null) return false;
    _settings = SettingsData(data['UpdateUser']);
    return true;
  }
}

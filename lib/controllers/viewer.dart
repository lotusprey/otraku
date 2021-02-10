import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/helpers/scroll_x_controller.dart';
import 'package:otraku/models/anilist/activity_model.dart';
import 'package:otraku/models/anilist/settings_data.dart';
import 'package:otraku/models/loadable_list.dart';

class Viewer extends ScrollxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _viewerQuery = r'''
    query ViewerData($withMain: Boolean = false, $page: Int = 1, $isFollowing: Boolean = false) {
      Viewer {unreadNotificationCount ...main @include(if: $withMain)}
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(isFollowing: $isFollowing, sort: ID_DESC) {
          ... on TextActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            createdAt
            user {id name avatar {large}}
            text(asHtml: true)
          }
          ... on ListActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            createdAt
            user {id name avatar {large}}
            media {id type title{userPreferred} coverImage{large}}
            progress
            status
          }
          ... on MessageActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            createdAt
            recipient {id name avatar {large}}
            messenger {id name avatar {large}}
            message(asHtml: true)
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

  final _activities = Rx<LoadableList<ActivityModel>>();
  final _unreadCount = 0.obs;
  final List<int> _idNotIn = [];
  final List<ActivityType> _typeIn = ActivityType.values;
  bool isFollowing = true;
  SettingsData _settings;
  bool _fetching = false;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  List<ActivityModel> get activities => _activities()?.items;

  List<ActivityType> get typeIn => [..._typeIn];

  int get unreadCount => _unreadCount();

  void updateFilters(final bool following, final List<ActivityType> types) {
    isFollowing = following;
    typeIn.replaceRange(0, typeIn.length, types);
    refetch();
  }

  SettingsData get settings => _settings;

  void nullifyUnread() => _unreadCount.value = 0;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchData() async {
    final data = await Network.request(
      _viewerQuery,
      {
        'withMain': true,
        'id_not_in': _idNotIn,
        'type_in': _typeIn.map((t) => describeEnum(t)).toList(),
        'isFollowing': isFollowing,
      },
      popOnErr: false,
    );
    if (data == null) return;

    _settings = SettingsData(data['Viewer']);
    _unreadCount.value = data['Viewer']['unreadNotificationCount'];
    update();

    _initActivities(data, true);
  }

  Future<void> fetchPage() async {
    if (_fetching || !_activities().hasNextPage) return;
    _fetching = true;

    final data = await Network.request(
      _viewerQuery,
      {
        'page': _activities().nextPage,
        'id_not_in': _idNotIn,
        'type_in': _typeIn.map((t) => describeEnum(t)).toList(),
        'isFollowing': isFollowing,
      },
      popOnErr: false,
    );
    if (data == null) return;

    _initActivities(data, false);
    _fetching = false;
  }

  Future<void> refetch() async {
    _fetching = true;
    final data = await Network.request(
      _viewerQuery,
      {
        'id_not_in': _idNotIn,
        'type_in': _typeIn.map((t) => describeEnum(t)).toList(),
        'isFollowing': isFollowing,
      },
      popOnErr: false,
    );
    if (data == null) return;

    _initActivities(data, true);
    _fetching = false;
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data = await Network.request(_settingsMutation, variables);
    if (data == null) return false;
    _settings = SettingsData(data['UpdateUser']);
    return true;
  }

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initActivities(final Map<String, dynamic> data, final bool replace) {
    if (replace) _idNotIn.clear();

    final List<ActivityModel> al = [];
    for (final a in data['Page']['activities']) {
      al.add(ActivityModel(a));
      _idNotIn.add(al.last.id);
    }

    if (replace)
      _activities(LoadableList(al, data['Page']['pageInfo']['hasNextPage']));
    else
      _activities.update(
        (a) => a.append(al, data['Page']['pageInfo']['hasNextPage']),
      );
  }
}

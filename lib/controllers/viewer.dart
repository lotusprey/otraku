import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/scroll_x_controller.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/models/page_model.dart';

class Viewer extends ScrollxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _viewerQuery = r'''
    query ViewerData($withMain: Boolean = false, $page: Int = 1, $isFollowing: Boolean = false, $hasRepliesOrTypeText: Boolean, $type_in: [ActivityType]) {
      Viewer {unreadNotificationCount ...main @include(if: $withMain)}
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(isFollowing: $isFollowing, hasRepliesOrTypeText: $hasRepliesOrTypeText, type_in: $type_in, sort: ID_DESC) {
          ... on TextActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            isSubscribed
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
            isSubscribed
            createdAt
            user {id name avatar {large}}
            media {id type title{userPreferred} coverImage{large} format}
            progress
            status
          }
          ... on MessageActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            isSubscribed
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
        animeList {splitCompletedSectionByFormat customLists advancedScoringEnabled}
        mangaList {splitCompletedSectionByFormat customLists}
      }
    }
  ''';

  static const _settingsMutation = r'''
    mutation UpdateSettings($about: String, $titleLanguage: UserTitleLanguage, 
        $displayAdultContent: Boolean, $airingNotifications: Boolean, $scoreFormat: ScoreFormat, $rowOrder: String, 
        $notificationOptions: [NotificationOptionInput], $splitCompletedAnime: Boolean, 
        $splitCompletedManga: Boolean, $advancedScoringEnabled: Boolean) {
      UpdateUser(about: $about, titleLanguage: $titleLanguage, 
          displayAdultContent: $displayAdultContent, airingNotifications: $airingNotifications,
          scoreFormat: $scoreFormat, rowOrder: $rowOrder, notificationOptions: $notificationOptions,
          animeListOptions: {splitCompletedSectionByFormat: $splitCompletedAnime, advancedScoringEnabled: $advancedScoringEnabled},
          mangaListOptions: {splitCompletedSectionByFormat: $splitCompletedManga, advancedScoringEnabled: $advancedScoringEnabled}) {
        options {
          titleLanguage 
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

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final _activities = PageModel<ActivityModel>().obs;
  final _unreadCount = 0.obs;
  final _idNotIn = <int>[];
  final _typeIn = [
    ActivityType.TEXT,
    ActivityType.ANIME_LIST,
    ActivityType.MANGA_LIST,
  ];
  bool _onFollowing = Config.storage.read(Config.FOLLOWING_FEED) ?? true;
  SettingsModel? _settings;
  bool _isLoading = true;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  List<ActivityModel> get activities => _activities().items;
  List<ActivityType> get typeIn => [..._typeIn];
  SettingsModel? get settings => _settings;
  int get unreadCount => _unreadCount();
  bool get onFollowing => _onFollowing;
  bool get isLoading => _isLoading;

  @override
  bool get hasNextPage => _activities().hasNextPage;

  void updateFilters({bool? following, List<ActivityType>? types}) {
    if (following != null) {
      _onFollowing = following;
      Config.storage.write(Config.FOLLOWING_FEED, following);
    }
    if (types != null) _typeIn.replaceRange(0, _typeIn.length, types);
    refetch();
  }

  void nullifyUnread() {
    _unreadCount.value = 0;
    Config.storage.write(Config.LAST_NOTIFICATION_COUNT, 0);
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    _isLoading = true;
    final data = await Client.request(
      _viewerQuery,
      {
        'withMain': true,
        'id_not_in': _idNotIn,
        'type_in': _typeIn.map((t) => describeEnum(t)).toList(),
        'isFollowing': _onFollowing,
        'hasRepliesOrTypeText': _onFollowing ? null : true,
      },
      popOnErr: false,
    );
    if (data == null) return;

    if (_settings == null) _settings = SettingsModel(data['Viewer']);
    _unreadCount.value = data['Viewer']['unreadNotificationCount'] ?? 0;
    Config.storage.write(Config.LAST_NOTIFICATION_COUNT, _unreadCount());
    update();

    _initActivities(data, true);
    _isLoading = false;
  }

  @override
  Future<void> fetchPage() async {
    _isLoading = true;

    final data = await Client.request(
      _viewerQuery,
      {
        'page': _activities().nextPage,
        'id_not_in': _idNotIn,
        'type_in': _typeIn.map((t) => describeEnum(t)).toList(),
        'isFollowing': _onFollowing,
        'hasRepliesOrTypeText': _onFollowing ? null : true,
      },
      popOnErr: false,
    );
    if (data == null) return;

    _initActivities(data, false);
    _isLoading = false;
  }

  Future<void> refetch() async {
    _isLoading = true;
    _activities.update((a) => a?.items.clear());

    final data = await Client.request(
      _viewerQuery,
      {
        'id_not_in': _idNotIn,
        'type_in': _typeIn.map((t) => describeEnum(t)).toList(),
        'isFollowing': _onFollowing,
        'hasRepliesOrTypeText': _onFollowing ? null : true,
      },
      popOnErr: false,
    );
    if (data == null) return;

    _initActivities(data, true);
    _isLoading = false;
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data =
        await Client.request(_settingsMutation, variables, popOnErr: false);
    if (data == null) return false;
    _settings = SettingsModel(data['UpdateUser']);
    return true;
  }

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initActivities(Map<String, dynamic> data, bool clear) {
    if (clear) {
      _idNotIn.clear();
      _activities().clear();
      scrollTo(0);
    }

    final al = <ActivityModel>[];
    for (final a in data['Page']['activities']) {
      try {
        al.add(ActivityModel(a));
        _idNotIn.add(al.last.id);
      } catch (_) {}
    }

    _activities.update(
      (a) => a!.append(al, data['Page']['pageInfo']['hasNextPage']),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}

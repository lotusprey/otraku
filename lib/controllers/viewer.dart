import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/utils/client.dart';
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

  final _activities = Rx<PageModel<ActivityModel>>();
  final _unreadCount = 0.obs;
  final List<int> _idNotIn = [];
  final List<ActivityType> _typeIn = [
    ActivityType.TEXT,
    ActivityType.ANIME_LIST,
    ActivityType.MANGA_LIST,
  ];
  bool _onFollowing = true;
  SettingsModel? _settings;
  bool _isLoading = true;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  List<ActivityModel>? get activities => _activities()?.items;
  List<ActivityType> get typeIn => [..._typeIn];
  SettingsModel? get settings => _settings;
  int get unreadCount => _unreadCount();
  bool get onFollowing => _onFollowing;
  bool get isLoading => _isLoading;

  void updateFilters({bool? following, List<ActivityType>? types}) {
    if (following != null) _onFollowing = following;
    if (types != null) _typeIn.replaceRange(0, _typeIn.length, types);
    refetch();
  }

  void nullifyUnread() => _unreadCount.value = 0;

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

    _settings = SettingsModel(data['Viewer']);
    _unreadCount.value = data['Viewer']['unreadNotificationCount'];
    update();

    _initActivities(data, true);
    _isLoading = false;
  }

  Future<void> fetchPage() async {
    if (_isLoading || !_activities()!.hasNextPage!) return;
    _isLoading = true;

    final data = await Client.request(
      _viewerQuery,
      {
        'page': _activities()!.nextPage,
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
    final data = await Client.request(_settingsMutation, variables);
    if (data == null) return false;
    _settings = SettingsModel(data['UpdateUser']);
    return true;
  }

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initActivities(final Map<String, dynamic> data, final bool replace) {
    if (replace) {
      _idNotIn.clear();
      scrollTo(0);
    }

    final List<ActivityModel> al = [];
    for (final a in data['Page']['activities']) {
      final m = ActivityModel(a);
      if (!m.valid) continue;
      al.add(m);
      _idNotIn.add(al.last.id);
    }

    if (replace)
      _activities(PageModel(al, data['Page']['pageInfo']['hasNextPage'], 2));
    else
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

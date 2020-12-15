import 'package:get/get.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/models/settings.dart';
import 'package:otraku/models/user.dart';
import 'package:otraku/controllers/network_service.dart';

class Users extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _viewerQuery = r'''
    query {
      Viewer {
        id
        name
        about(asHtml: true)
        avatar {large}
        bannerImage
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
    }
  ''';

  static const _userQuery = r'''
      query User($id: Int) {
        User(id: $id) {
          name
          about(asHtml: true)
          avatar {large}
          bannerImage
          isFollowing
          isFollower
          isBlocked
          mediaListOptions {scoreFormat}
        }
      }
    ''';

  static const _viewerMutation = r'''
    mutation UpdateUser($about: String, $titleLanguage: UserTitleLanguage, 
        $displayAdultContent: Boolean, $airingNotifications: Boolean, $scoreFormat: ScoreFormat, $rowOrder: String, 
        $notificationOptions: [NotificationOptionInput], $splitCompletedAnime: Boolean, 
        $splitCompletedManga: Boolean,) {
      UpdateUser(about: $about, titleLanguage: $titleLanguage, 
          displayAdultContent: $displayAdultContent, airingNotifications: $airingNotifications,
          scoreFormat: $scoreFormat, rowOrder: $rowOrder, notificationOptions: $notificationOptions,
          animeListOptions: {splitCompletedSectionByFormat: $splitCompletedAnime},
          mangaListOptions: {splitCompletedSectionByFormat: $splitCompletedManga}) {
        about
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

  final _me = User().obs;
  final _them = User().obs;
  Settings _settings;

  User get me => _me();

  User them(int id) {
    if (_them().id != id) {
      fetchUser(id);
      return _them(User());
    }
    return _them();
  }

  Settings get settings => _settings;

  // ***************************************************************************
  // DATA FETCHING
  // ***************************************************************************

  Future<void> fetchViewer() async {
    final data =
        await NetworkService.request(_viewerQuery, null, popOnError: false);

    if (data == null) return;
    final viewer = data['Viewer'];

    _me(User(
      id: viewer['id'],
      name: viewer['name'],
      description: viewer['about'],
      avatar: viewer['avatar']['large'],
      banner: viewer['bannerImage'],
      isMe: true,
    ));

    _createSettings(viewer);
  }

  Future<void> fetchUser(int id) async {
    final data = await NetworkService.request(_userQuery, {'id': id});

    if (data == null) return;

    _them(User(
      id: id,
      name: data['User']['name'],
      description: data['User']['about'],
      avatar: data['User']['avatar']['large'],
      banner: data['User']['bannerImage'],
      isMe: false,
    ));
  }

  Future<Settings> updateSettings(Map<String, dynamic> variables) async {
    final data = await NetworkService.request(_viewerMutation, variables);

    if (data == null) return null;

    _createSettings(data['UpdateUser']);

    return _settings;
  }

  // ***************************************************************************
  // HELPER FUNCTIONS FOR CLEANER CODE
  // ***************************************************************************

  void _createSettings(Map<String, dynamic> viewer) {
    _settings = Settings(
      scoreFormat: stringToEnum(
        viewer['mediaListOptions']['scoreFormat'],
        ScoreFormat.values,
      ),
      defaultSort:
          ListSortHelper.getEnum(viewer['mediaListOptions']['rowOrder']),
      titleLanguage: viewer['options']['titleLanguage'],
      splitCompletedAnime: viewer['mediaListOptions']['animeList']
          ['splitCompletedSectionByFormat'],
      splitCompletedManga: viewer['mediaListOptions']['mangaList']
          ['splitCompletedSectionByFormat'],
      displayAdultContent: viewer['options']['displayAdultContent'],
      airingNotifications: viewer['options']['airingNotifications'],
      notificationOptions: Map.fromIterable(
        viewer['options']['notificationOptions'],
        key: (n) => n['type'],
        value: (n) => n['enabled'],
      ),
    );
  }
}

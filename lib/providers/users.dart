import 'package:flutter/cupertino.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/models/settings.dart';
import 'package:otraku/models/user.dart';
import 'package:otraku/providers/network_service.dart';

class Users with ChangeNotifier {
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
        $displayAdultContent: Boolean, $scoreFormat: ScoreFormat, 
        $rowOrder: String, $splitCompletedAnime: Boolean, $splitCompletedManga: Boolean) {
      UpdateUser(about: $about, titleLanguage: $titleLanguage, 
          displayAdultContent: $displayAdultContent, scoreFormat: $scoreFormat,
          rowOrder: $rowOrder, animeListOptions: {splitCompletedSectionByFormat: $splitCompletedAnime},
          mangaListOptions: {splitCompletedSectionByFormat: $splitCompletedManga}) {
        about
        options {titleLanguage displayAdultContent}
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

  User _me;
  User _them;
  Settings _settings;

  User get me => _me;

  User them(int id) {
    if (_them == null || _them.id != id) fetchUser(id);
    return _them;
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

    _me = User(
      id: viewer['id'],
      name: viewer['name'],
      description: viewer['about'],
      avatar: viewer['avatar']['large'],
      banner: viewer['bannerImage'],
      isMe: true,
    );

    _settings = Settings(
      stringToEnum(
        viewer['mediaListOptions']['scoreFormat'],
        ScoreFormat.values,
      ),
      defaultSortFromString(viewer['rowOrder']),
      viewer['options']['titleLanguage'],
      viewer['mediaListOptions']['animeList']['splitCompletedSectionByFormat'],
      viewer['mediaListOptions']['mangaList']['splitCompletedSectionByFormat'],
      viewer['options']['displayAdultContent'],
    );

    notifyListeners();
  }

  Future<void> fetchUser(int id) async {
    final data = await NetworkService.request(_userQuery, {'id': id});

    if (data == null) return;

    _them = User(
      id: id,
      name: data['User']['name'],
      description: data['User']['about'],
      avatar: data['User']['avatar']['large'],
      banner: data['User']['bannerImage'],
      isMe: false,
    );

    notifyListeners();
  }

  Future<Settings> updateSettings(Map<String, dynamic> variables) async {
    final data = await NetworkService.request(_viewerMutation, variables);

    if (data == null) return null;

    final viewer = data['UpdateUser'];

    _settings = Settings(
      stringToEnum(
        viewer['mediaListOptions']['scoreFormat'],
        ScoreFormat.values,
      ),
      defaultSortFromString(viewer['rowOrder']),
      viewer['options']['titleLanguage'],
      viewer['mediaListOptions']['animeList']['splitCompletedSectionByFormat'],
      viewer['mediaListOptions']['mangaList']['splitCompletedSectionByFormat'],
      viewer['options']['displayAdultContent'],
    );

    return _settings;
  }
}

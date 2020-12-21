import 'package:flutter/foundation.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/score_format_enum.dart';

class Settings {
  final ScoreFormat scoreFormat;
  final ListSort defaultSort;
  final String titleLanguage;
  final bool splitCompletedAnime;
  final bool splitCompletedManga;
  final bool displayAdultContent;
  final bool airingNotifications;
  final Map<String, bool> notificationOptions;

  Settings._({
    @required this.scoreFormat,
    @required this.defaultSort,
    @required this.titleLanguage,
    @required this.splitCompletedAnime,
    @required this.splitCompletedManga,
    @required this.displayAdultContent,
    @required this.airingNotifications,
    @required this.notificationOptions,
  });

  factory Settings(Map<String, dynamic> map) => Settings._(
        scoreFormat: stringToEnum(
          map['mediaListOptions']['scoreFormat'],
          ScoreFormat.values,
        ),
        defaultSort:
            ListSortHelper.getEnum(map['mediaListOptions']['rowOrder']),
        titleLanguage: map['options']['titleLanguage'],
        splitCompletedAnime: map['mediaListOptions']['animeList']
            ['splitCompletedSectionByFormat'],
        splitCompletedManga: map['mediaListOptions']['mangaList']
            ['splitCompletedSectionByFormat'],
        displayAdultContent: map['options']['displayAdultContent'],
        airingNotifications: map['options']['airingNotifications'],
        notificationOptions: Map.fromIterable(
          map['options']['notificationOptions'],
          key: (n) => n['type'],
          value: (n) => n['enabled'],
        ),
      );
}

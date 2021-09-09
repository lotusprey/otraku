import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/score_format.dart';

class SettingsModel {
  final ScoreFormat scoreFormat;
  final EntrySort defaultSort;
  final String titleLanguage;
  final String staffNameLanguage;
  final int activityMergeTime;
  final bool splitCompletedAnime;
  final bool splitCompletedManga;
  final bool displayAdultContent;
  final bool airingNotifications;
  final bool advancedScoringEnabled;
  final Map<String, bool> notificationOptions;

  SettingsModel._({
    required this.scoreFormat,
    required this.defaultSort,
    required this.titleLanguage,
    required this.staffNameLanguage,
    required this.activityMergeTime,
    required this.splitCompletedAnime,
    required this.splitCompletedManga,
    required this.airingNotifications,
    required this.displayAdultContent,
    required this.advancedScoringEnabled,
    required this.notificationOptions,
  });

  factory SettingsModel(Map<String, dynamic> map) => SettingsModel._(
        scoreFormat: Convert.strToEnum(
              map['mediaListOptions']['scoreFormat'],
              ScoreFormat.values,
            ) ??
            ScoreFormat.POINT_10,
        defaultSort:
            EntrySortHelper.getEnum(map['mediaListOptions']['rowOrder']),
        titleLanguage: map['options']['titleLanguage'] ?? 'ROMAJI',
        staffNameLanguage:
            map['options']['staffNameLanguage'] ?? 'ROMAJI_WESTERN',
        activityMergeTime: map['options']['activityMergeTime'] ?? 720,
        splitCompletedAnime: map['mediaListOptions']['animeList']
                ['splitCompletedSectionByFormat'] ??
            false,
        splitCompletedManga: map['mediaListOptions']['mangaList']
                ['splitCompletedSectionByFormat'] ??
            false,
        displayAdultContent: map['options']['displayAdultContent'] ?? false,
        airingNotifications: map['options']['airingNotifications'] ?? false,
        advancedScoringEnabled: map['mediaListOptions']['animeList']
                ['advancedScoringEnabled'] ??
            false,
        notificationOptions: Map.fromIterable(
          map['options']['notificationOptions'],
          key: (n) => n['type'],
          value: (n) => n['enabled'],
        ),
      );
}

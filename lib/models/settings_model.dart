import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/score_format.dart';

class SettingsModel {
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
    required this.advancedScores,
    required this.notificationOptions,
  });

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
  final List<String> advancedScores;
  final Map<String, bool> notificationOptions;

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
        advancedScores: List<String>.from(
          map['mediaListOptions']['animeList']['advancedScoring'] ?? [],
        ),
        notificationOptions: Map.fromIterable(
          map['options']['notificationOptions'],
          key: (n) => n['type'],
          value: (n) => n['enabled'],
        ),
      );
}

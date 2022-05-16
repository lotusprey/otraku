import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/providers/notifications.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';

final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>(
  (ref) => UserSettingsNotifier(),
);

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(UserSettings._()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final data = await Client.get(GqlQuery.settings);
      if (data.isEmpty) return;
      state = UserSettings(data['Viewer']);
    } catch (e) {}
  }

  Future<void> update(UserSettings other) async {
    try {
      final data = await Client.get(GqlMutation.updateSettings, other.toMap());
      if (data.isEmpty) return;
      state = UserSettings(data['UpdateUser']);
    } catch (_) {}
  }

  void nullifyUnread() => state = state.copy();
}

/// Some fields are modifiable to allow for quick and simple edits.
/// But to apply those edits, the [UserSettingsNotifier] should be used.
class UserSettings {
  UserSettings._({
    this.notificationCount = 0,
    this.scoreFormat = ScoreFormat.POINT_10,
    this.defaultSort = EntrySort.TITLE,
    this.titleLanguage = 'ROMAJI',
    this.staffNameLanguage = 'ROMAJI_WESTERN',
    this.activityMergeTime = 720,
    this.splitCompletedAnime = false,
    this.splitCompletedManga = false,
    this.airingNotifications = true,
    this.displayAdultContent = false,
    this.advancedScoringEnabled = false,
    this.advancedScores = const [],
    this.animeCustomLists = const [],
    this.mangaCustomLists = const [],
    this.notificationOptions = const {},
  });

  factory UserSettings(Map<String, dynamic> map) => UserSettings._(
        notificationCount: map['unreadNotificationCount'] ?? 0,
        scoreFormat: ScoreFormat.values.byName(
          map['mediaListOptions']['scoreFormat'] ?? 'POINT_10',
        ),
        defaultSort: EntrySort.getEnum(
          map['mediaListOptions']['rowOrder'],
        ),
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
        airingNotifications: map['options']['airingNotifications'] ?? true,
        advancedScoringEnabled: map['mediaListOptions']['animeList']
                ['advancedScoringEnabled'] ??
            false,
        advancedScores: List<String>.from(
          map['mediaListOptions']['animeList']['advancedScoring'] ?? [],
        ),
        animeCustomLists: List<String>.from(
          map['mediaListOptions']['animeList']['customLists'] ?? [],
        ),
        mangaCustomLists: List<String>.from(
          map['mediaListOptions']['mangaList']['customLists'] ?? [],
        ),
        notificationOptions: Map.fromIterable(
          map['options']['notificationOptions'],
          key: (n) => NotificationType.values.byName(n['type']),
          value: (n) => n['enabled'],
        ),
      );

  ScoreFormat scoreFormat;
  EntrySort defaultSort;
  String titleLanguage;
  String staffNameLanguage;
  int activityMergeTime;
  bool splitCompletedAnime;
  bool splitCompletedManga;
  bool displayAdultContent;
  bool airingNotifications;
  bool advancedScoringEnabled;
  final int notificationCount;
  final List<String> advancedScores;
  final List<String> animeCustomLists;
  final List<String> mangaCustomLists;
  final Map<NotificationType, bool> notificationOptions;

  UserSettings copy({int notificationCount = 0}) => UserSettings._(
        notificationCount: notificationCount,
        scoreFormat: scoreFormat,
        defaultSort: defaultSort,
        titleLanguage: titleLanguage,
        staffNameLanguage: staffNameLanguage,
        activityMergeTime: activityMergeTime,
        splitCompletedAnime: splitCompletedAnime,
        splitCompletedManga: splitCompletedManga,
        displayAdultContent: displayAdultContent,
        airingNotifications: airingNotifications,
        advancedScoringEnabled: advancedScoringEnabled,
        advancedScores: [...advancedScores],
        animeCustomLists: [...animeCustomLists],
        mangaCustomLists: [...mangaCustomLists],
        notificationOptions: {...notificationOptions},
      );

  Map<String, dynamic> toMap() => {
        'titleLanguage': titleLanguage,
        'staffNameLanguage': staffNameLanguage,
        'activityMergeTime': activityMergeTime,
        'displayAdultContent': displayAdultContent,
        'scoreFormat': scoreFormat.name,
        'rowOrder': defaultSort.getString,
        'advancedScoring': advancedScores,
        'advancedScoringEnabled': advancedScoringEnabled,
        'splitCompletedAnime': splitCompletedAnime,
        'splitCompletedManga': splitCompletedManga,
        'airingNotifications': airingNotifications,
        'notificationOptions': notificationOptions.entries
            .map((e) => {'type': e.key.name, 'enabled': e.value})
            .toList(),
      };
}

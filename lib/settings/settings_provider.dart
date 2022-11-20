import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/notifications/notification_model.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<Settings>>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<AsyncValue<Settings>> {
  SettingsNotifier() : super(const AsyncValue.loading()) {
    _fetch();
  }

  /// Different parts of the app may need the settings at any moment,
  /// so a default instance is provided while loading.
  Settings get value => state.maybeWhen(
        data: (data) => data,
        orElse: () => Settings.empty(),
      );

  Future<void> _fetch() async {
    state = await AsyncValue.guard(() async {
      final data = await Api.get(GqlQuery.settings);
      return Settings(data['Viewer']);
    });
  }

  Future<void> update(Settings other) async {
    state = await AsyncValue.guard(() async {
      final data = await Api.get(GqlMutation.updateSettings, other.toMap());
      return Settings(data['UpdateUser']);
    });
  }

  Future<void> refetchUnread() async {
    try {
      final data = await Api.get(GqlQuery.settings, {'withData': false});
      state = state.whenData(
        (value) => value.copy(
          unreadNotifications: data['Viewer']['unreadNotificationCount'] ?? 0,
        ),
      );
    } catch (_) {}
  }

  void clearUnread() =>
      state = state.whenData((value) => value.copy(unreadNotifications: 0));
}

/// Some fields are modifiable to allow for quick and simple edits.
/// But to apply those edits, the [SettingsNotifier] should be used.
class Settings {
  Settings._({
    required this.unreadNotifications,
    required this.scoreFormat,
    required this.defaultSort,
    required this.titleLanguage,
    required this.staffNameLanguage,
    required this.activityMergeTime,
    required this.splitCompletedAnime,
    required this.splitCompletedManga,
    required this.displayAdultContent,
    required this.airingNotifications,
    required this.advancedScoringEnabled,
    required this.restrictMessagesToFollowing,
    required this.advancedScores,
    required this.animeCustomLists,
    required this.mangaCustomLists,
    required this.disabledListActivity,
    required this.notificationOptions,
  });

  factory Settings(Map<String, dynamic> map) => Settings._(
        unreadNotifications: map['unreadNotificationCount'] ?? 0,
        scoreFormat: ScoreFormat.values.byName(
          map['mediaListOptions']['scoreFormat'] ?? 'POINT_10',
        ),
        defaultSort: EntrySort.getEnum(
          map['mediaListOptions']['rowOrder'] ?? 'TITLE',
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
        restrictMessagesToFollowing:
            map['options']['restrictMessagesToFollowing'] ?? false,
        advancedScores: List<String>.from(
          map['mediaListOptions']['animeList']['advancedScoring'] ?? <String>[],
        ),
        animeCustomLists: List<String>.from(
          map['mediaListOptions']['animeList']['customLists'] ?? <String>[],
        ),
        mangaCustomLists: List<String>.from(
          map['mediaListOptions']['mangaList']['customLists'] ?? <String>[],
        ),
        disabledListActivity: {
          for (var n in map['options']['disabledListActivity'])
            EntryStatus.values.byName(n['type']): n['disabled']
        },
        notificationOptions: {
          for (var n in map['options']['notificationOptions'])
            NotificationType.values.byName(n['type']): n['enabled']
        },
      );

  factory Settings.empty() => Settings._(
        unreadNotifications: 0,
        scoreFormat: ScoreFormat.POINT_10,
        defaultSort: EntrySort.TITLE,
        titleLanguage: 'ROMAJI',
        staffNameLanguage: 'ROMAJI_WESTERN',
        activityMergeTime: 720,
        splitCompletedAnime: false,
        splitCompletedManga: false,
        displayAdultContent: false,
        airingNotifications: true,
        advancedScoringEnabled: false,
        restrictMessagesToFollowing: false,
        advancedScores: [],
        animeCustomLists: [],
        mangaCustomLists: [],
        disabledListActivity: {},
        notificationOptions: {},
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
  bool restrictMessagesToFollowing;
  final int unreadNotifications;
  final List<String> advancedScores;
  final List<String> animeCustomLists;
  final List<String> mangaCustomLists;
  final Map<EntryStatus, bool> disabledListActivity;
  final Map<NotificationType, bool> notificationOptions;

  Settings copy({int unreadNotifications = 0}) => Settings._(
        unreadNotifications: unreadNotifications,
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
        restrictMessagesToFollowing: restrictMessagesToFollowing,
        advancedScores: [...advancedScores],
        animeCustomLists: [...animeCustomLists],
        mangaCustomLists: [...mangaCustomLists],
        disabledListActivity: {...disabledListActivity},
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
        'restrictMessagesToFollowing': restrictMessagesToFollowing,
        'airingNotifications': airingNotifications,
        'disabledListActivity': disabledListActivity.entries
            .map((e) => {'type': e.key.name, 'disabled': e.value})
            .toList(),
        'notificationOptions': notificationOptions.entries
            .map((e) => {'type': e.key.name, 'enabled': e.value})
            .toList(),
      };
}

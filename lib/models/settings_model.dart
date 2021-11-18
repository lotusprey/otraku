import 'package:flutter/material.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/utils/theming.dart';

class LocalSettings {
  static const _THEME_MODE = 'themeMode';
  static const _LIGHT_THEME = 'theme1';
  static const _DARK_THEME = 'theme2';
  static const _DEFAULT_HOME_TAB = 'defaultHomeTab';
  static const _DEFAULT_EXPLORABLE = 'defaultExplorable';
  static const _DEFAULT_ANIME_SORT = 'defaultAnimeSort';
  static const _DEFAULT_MANGA_SORT = 'defaultMangaSort';
  static const _DEFAULT_EXPLORE_SORT = 'defaultExploreSort';
  static const _CONFIRM_EXIT = 'confirmExit';
  static const _LEFT_HANDED = 'leftHanded';
  static const _ANALOGUE_CLOCK = 'analogueClock';
  static const _LAST_FEED = 'lastFeed';
  static const _NOTIFICATION_COUNT = 'notificationCount';

  LocalSettings._(
    this._themeMode,
    this._lightTheme,
    this._darkTheme,
    this._defaultHomeTab,
    this._defaultExplorable,
    this._defaultAnimeSort,
    this._defaultMangaSort,
    this._defaultExploreSort,
    this._confirmExit,
    this._leftHanded,
    this._analogueClock,
    this._lastFeed,
    this._notificationCount,
  );

  ThemeMode _themeMode;
  int _lightTheme;
  int _darkTheme;
  int _defaultHomeTab;
  Explorable _defaultExplorable;
  EntrySort _defaultAnimeSort;
  EntrySort _defaultMangaSort;
  MediaSort _defaultExploreSort;
  bool _confirmExit;
  bool _leftHanded;
  bool _analogueClock;
  bool _lastFeed;
  int _notificationCount;

  ThemeMode get themeMode => _themeMode;
  int get lightTheme => _lightTheme;
  int get darkTheme => _darkTheme;
  int get defaultHomeTab => _defaultHomeTab;
  Explorable get defaultExplorable => _defaultExplorable;
  EntrySort get defaultAnimeSort => _defaultAnimeSort;
  EntrySort get defaultMangaSort => _defaultMangaSort;
  MediaSort get defaultExploreSort => _defaultExploreSort;
  bool get confirmExit => _confirmExit;
  bool get leftHanded => _leftHanded;
  bool get analogueClock => _analogueClock;
  bool get lastFeed => _lastFeed;
  int get notificationCount => _notificationCount;

  set themeMode(ThemeMode v) {
    if (v == _themeMode) return;
    _themeMode = v;
    Theming.it.refresh();
    Config.storage.write(_THEME_MODE, v.index);
  }

  set lightTheme(int v) {
    if (v < 0 || v >= Theming.themeCount || v == _lightTheme) return;
    _lightTheme = v;
    Theming.it.refresh();
    Config.storage.write(_LIGHT_THEME, v);
  }

  set darkTheme(int v) {
    if (v < 0 || v >= Theming.themeCount || v == _darkTheme) return;
    _darkTheme = v;
    Theming.it.refresh();
    Config.storage.write(_DARK_THEME, v);
  }

  set defaultHomeTab(int v) {
    if (v < 0 || v > 4) return;
    _defaultHomeTab = v;
    Config.storage.write(_DEFAULT_HOME_TAB, v);
  }

  set defaultExplorable(Explorable v) {
    _defaultExplorable = v;
    Config.storage.write(_DEFAULT_EXPLORABLE, v.index);
  }

  set defaultAnimeSort(EntrySort v) {
    _defaultAnimeSort = v;
    Config.storage.write(_DEFAULT_ANIME_SORT, v.index);
  }

  set defaultMangaSort(EntrySort v) {
    _defaultMangaSort = v;
    Config.storage.write(_DEFAULT_MANGA_SORT, v.index);
  }

  set defaultExploreSort(MediaSort v) {
    _defaultExploreSort = v;
    Config.storage.write(_DEFAULT_EXPLORE_SORT, v.index);
  }

  set confirmExit(bool v) {
    _confirmExit = v;
    Config.storage.write(_CONFIRM_EXIT, v);
  }

  set leftHanded(bool v) {
    _leftHanded = v;
    Config.storage.write(_LEFT_HANDED, v);
  }

  set analogueClock(bool v) {
    _analogueClock = v;
    Config.storage.write(_ANALOGUE_CLOCK, v);
  }

  set lastFeed(bool v) {
    _lastFeed = v;
    Config.storage.write(_LAST_FEED, v);
  }

  set notificationCount(int v) {
    if (v < 0) return;
    _notificationCount = v;
    Config.storage.write(_NOTIFICATION_COUNT, v);
  }

  factory LocalSettings() => LocalSettings._(
        ThemeMode.values[(Config.storage.read(_THEME_MODE) ?? 0)],
        Config.storage.read(_LIGHT_THEME) ?? 0,
        Config.storage.read(_DARK_THEME) ?? 0,
        Config.storage.read(_DEFAULT_HOME_TAB) ?? 0,
        Explorable.values[Config.storage.read(_DEFAULT_EXPLORABLE) ?? 0],
        EntrySort.values[Config.storage.read(_DEFAULT_ANIME_SORT) ?? 0],
        EntrySort.values[Config.storage.read(_DEFAULT_MANGA_SORT) ?? 0],
        MediaSort.values[Config.storage.read(_DEFAULT_EXPLORE_SORT) ?? 0],
        Config.storage.read(_CONFIRM_EXIT) ?? false,
        Config.storage.read(_LEFT_HANDED) ?? false,
        Config.storage.read(_ANALOGUE_CLOCK) ?? false,
        Config.storage.read(_LAST_FEED) ?? false,
        Config.storage.read(_NOTIFICATION_COUNT) ?? 0,
      );
}

class SettingsSiteModel {
  SettingsSiteModel._({
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

  factory SettingsSiteModel(Map<String, dynamic> map) => SettingsSiteModel._(
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

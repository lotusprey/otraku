import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/utils/theming.dart';

// Local settings.
class Settings {
  Settings._(
    this._account,
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
    this._lastNotification,
    this._id0,
    this._id1,
    this._expiration0,
    this._expiration1,
  );

  factory Settings._read() {
    return Settings._(
      _box.get(_ACCOUNT),
      ThemeMode.values[(_box.get(_THEME_MODE) ?? 0)],
      _box.get(_LIGHT_THEME) ?? 0,
      _box.get(_DARK_THEME) ?? 0,
      _box.get(_DEFAULT_HOME_TAB) ?? 0,
      Explorable.values[_box.get(_DEFAULT_EXPLORABLE) ?? 0],
      EntrySort.values[_box.get(_DEFAULT_ANIME_SORT) ?? 0],
      EntrySort.values[_box.get(_DEFAULT_MANGA_SORT) ?? 0],
      MediaSort.values[
          _box.get(_DEFAULT_EXPLORE_SORT) ?? MediaSort.TRENDING_DESC.index],
      _box.get(_CONFIRM_EXIT) ?? false,
      _box.get(_LEFT_HANDED) ?? false,
      _box.get(_ANALOGUE_CLOCK) ?? false,
      _box.get(_LAST_FEED) ?? false,
      _box.get(_LAST_NOTIFICATION) ?? -1,
      _box.get(_ID_0),
      _box.get(_ID_1),
      _box.get(_EXPIRATION_0),
      _box.get(_EXPIRATION_1),
    );
  }

  factory Settings() => _it;

  static late Settings _it;

  static const _SETTINGS = 'settings';

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
  static const _LAST_NOTIFICATION = 'lastNotification0';
  static const _ID_0 = 'id0';
  static const _ID_1 = 'id1';
  static const _EXPIRATION_0 = 'expiration0';
  static const _EXPIRATION_1 = 'expiration1';
  static const _ACCOUNT = 'account';

  static bool _didInit = false;

  // Should be called before use.
  static Future<void> init() async {
    if (_didInit) return Future.value(true);
    _didInit = true;

    await Hive.initFlutter();
    await Hive.openBox(_SETTINGS);
    _it = Settings._read();
  }

  static Box get _box => Hive.box(_SETTINGS);

  int? _account;
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
  int _lastNotification;
  int? _id0;
  int? _id1;
  int? _expiration0;
  int? _expiration1;

  int? get selectedAccount => _account;
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
  int get lastNotification => _lastNotification;

  bool isAvailableAccount(int i) {
    if (i < 0 || i > 1) return false;
    return _box.get(i == 0 ? _ID_0 : _ID_1) != null;
  }

  int? get id {
    if (_account == null) return null;
    return _account == 0 ? _id0 : _id1;
  }

  int? idOf(int v) {
    if (v == 0) return _id0;
    if (v == 1) return _id1;
    return null;
  }

  int? expirationOf(int v) {
    if (v == 0) return _expiration0;
    if (v == 1) return _expiration1;
    return null;
  }

  set selectedAccount(int? v) {
    if (v == null && _account != null) {
      _account = null;
      _box.delete(_ACCOUNT);
      _it.lastNotification = -1;
    } else if (v == 0 && _account != 0) {
      _account = 0;
      _box.put(_ACCOUNT, 0);
    } else if (v == 1 && _account != 1) {
      _account = 1;
      _box.put(_ACCOUNT, 1);
    }
  }

  set themeMode(ThemeMode v) {
    if (v == _themeMode) return;
    _themeMode = v;
    Theming().refresh();
    _box.put(_THEME_MODE, v.index);
  }

  set lightTheme(int v) {
    if (v < 0 || v >= Theming.themeCount || v == _lightTheme) return;
    _lightTheme = v;
    Theming().refresh();
    _box.put(_LIGHT_THEME, v);
  }

  set darkTheme(int v) {
    if (v < 0 || v >= Theming.themeCount || v == _darkTheme) return;
    _darkTheme = v;
    Theming().refresh();
    _box.put(_DARK_THEME, v);
  }

  set defaultHomeTab(int v) {
    if (v < 0 || v > 4) return;
    _defaultHomeTab = v;
    _box.put(_DEFAULT_HOME_TAB, v);
  }

  set defaultExplorable(Explorable v) {
    _defaultExplorable = v;
    _box.put(_DEFAULT_EXPLORABLE, v.index);
  }

  set defaultAnimeSort(EntrySort v) {
    _defaultAnimeSort = v;
    _box.put(_DEFAULT_ANIME_SORT, v.index);
  }

  set defaultMangaSort(EntrySort v) {
    _defaultMangaSort = v;
    _box.put(_DEFAULT_MANGA_SORT, v.index);
  }

  set defaultExploreSort(MediaSort v) {
    _defaultExploreSort = v;
    _box.put(_DEFAULT_EXPLORE_SORT, v.index);
  }

  set confirmExit(bool v) {
    _confirmExit = v;
    _box.put(_CONFIRM_EXIT, v);
  }

  set leftHanded(bool v) {
    _leftHanded = v;
    _box.put(_LEFT_HANDED, v);
  }

  set analogueClock(bool v) {
    _analogueClock = v;
    _box.put(_ANALOGUE_CLOCK, v);
  }

  set lastFeed(bool v) {
    _lastFeed = v;
    _box.put(_LAST_FEED, v);
  }

  set lastNotification(int v) {
    _lastNotification = v;
    v > -1 ? _box.put(_LAST_NOTIFICATION, v) : _box.delete(_LAST_NOTIFICATION);
  }

  void setIdOf(int a, int? v) {
    if (a < 0 || a > 1) return;
    a == 0 ? _id0 = v : _id1 = v;
    v != null
        ? _box.put(a == 0 ? _ID_0 : _ID_1, v)
        : _box.delete(a == 0 ? _ID_0 : _ID_1);
  }

  void setExpirationOf(int a, int? v) {
    if (a < 0 || a > 1) return;
    a == 0 ? _expiration0 = v : _expiration1 = v;
    v != null
        ? _box.put(a == 0 ? _EXPIRATION_0 : _EXPIRATION_1, v)
        : _box.delete(a == 0 ? _EXPIRATION_0 : _EXPIRATION_1);
  }
}

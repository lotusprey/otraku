import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/utils/theming.dart';

class LocalSettings {
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
    this._id0,
    this._id1,
    this._expiration0,
    this._expiration1,
  );

  factory LocalSettings._read() {
    final s = _storage;
    return LocalSettings._(
      ThemeMode.values[(s.read(_THEME_MODE) ?? 0)],
      s.read(_LIGHT_THEME) ?? 0,
      s.read(_DARK_THEME) ?? 0,
      s.read(_DEFAULT_HOME_TAB) ?? 0,
      Explorable.values[s.read(_DEFAULT_EXPLORABLE) ?? 0],
      EntrySort.values[s.read(_DEFAULT_ANIME_SORT) ?? 0],
      EntrySort.values[s.read(_DEFAULT_MANGA_SORT) ?? 0],
      MediaSort.values[
          s.read(_DEFAULT_EXPLORE_SORT) ?? MediaSort.TRENDING_DESC.index],
      s.read(_CONFIRM_EXIT) ?? false,
      s.read(_LEFT_HANDED) ?? false,
      s.read(_ANALOGUE_CLOCK) ?? false,
      s.read(_LAST_FEED) ?? false,
      s.read(_NOTIFICATION_COUNT) ?? 0,
      s.read(_ID_0),
      s.read(_ID_1),
      s.read(_EXPIRATION_0),
      s.read(_EXPIRATION_1),
    );
  }

  factory LocalSettings() => _it;

  static late LocalSettings _it;

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
  static const _NOTIFICATION_COUNT = 'notificationCount';
  static const _ID_0 = 'id0';
  static const _ID_1 = 'id1';
  static const _EXPIRATION_0 = 'expiration0';
  static const _EXPIRATION_1 = 'expiration1';
  static const _ACCOUNT = 'account';

  static bool _didInit = false;

  // Should be called before operating on the storage.
  static Future<bool> init() async {
    if (_didInit) return Future.value(true);
    _didInit = true;
    //
    //
    //
    // LEGACY CODE. To be removed after the next update.
    GetStorage.init().then((_) => GetStorage().erase());
    //
    //
    //

    final ok = await GetStorage.init(_SETTINGS);
    _account = _storage.read(_ACCOUNT);
    _it = LocalSettings._read();

    return ok;
  }

  static int? _account;

  static bool? get onPrimaryAccount {
    if (_account == null) return null;
    return _account == 0 ? true : false;
  }

  static set onPrimaryAccount(bool? v) {
    if (v == null && _account != null)
      _account = null;
    else if (v == true && _account != 0)
      _account = 0;
    else if (v == false && _account != 1) _account = 1;
    _account != null
        ? _storage.write(_ACCOUNT, _account)
        : _storage.remove(_ACCOUNT);
  }

  static bool isAvailableAccount(bool primary) =>
      _storage.read(primary ? _ID_0 : _ID_1) != null;

  static GetStorage get _storage => GetStorage(_SETTINGS);

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
  int? _id0;
  int? _id1;
  int? _expiration0;
  int? _expiration1;

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
  int? get id0 => _id0;
  int? get id1 => _id1;
  int? get expiration0 => _expiration0;
  int? get expiration1 => _expiration1;

  int? get id {
    if (_account == null) return null;
    return _account == 0 ? _id0 : _id1;
  }

  int? get expiration {
    if (_account == null) return null;
    return _account == 0 ? _expiration0 : _expiration1;
  }

  set themeMode(ThemeMode v) {
    if (v == _themeMode) return;
    _themeMode = v;
    Theming().refresh();
    _storage.write(_THEME_MODE, v.index);
  }

  set lightTheme(int v) {
    if (v < 0 || v >= Theming.themeCount || v == _lightTheme) return;
    _lightTheme = v;
    Theming().refresh();
    _storage.write(_LIGHT_THEME, v);
  }

  set darkTheme(int v) {
    if (v < 0 || v >= Theming.themeCount || v == _darkTheme) return;
    _darkTheme = v;
    Theming().refresh();
    _storage.write(_DARK_THEME, v);
  }

  set defaultHomeTab(int v) {
    if (v < 0 || v > 4) return;
    _defaultHomeTab = v;
    _storage.write(_DEFAULT_HOME_TAB, v);
  }

  set defaultExplorable(Explorable v) {
    _defaultExplorable = v;
    _storage.write(_DEFAULT_EXPLORABLE, v.index);
  }

  set defaultAnimeSort(EntrySort v) {
    _defaultAnimeSort = v;
    _storage.write(_DEFAULT_ANIME_SORT, v.index);
  }

  set defaultMangaSort(EntrySort v) {
    _defaultMangaSort = v;
    _storage.write(_DEFAULT_MANGA_SORT, v.index);
  }

  set defaultExploreSort(MediaSort v) {
    _defaultExploreSort = v;
    _storage.write(_DEFAULT_EXPLORE_SORT, v.index);
  }

  set confirmExit(bool v) {
    _confirmExit = v;
    _storage.write(_CONFIRM_EXIT, v);
  }

  set leftHanded(bool v) {
    _leftHanded = v;
    _storage.write(_LEFT_HANDED, v);
  }

  set analogueClock(bool v) {
    _analogueClock = v;
    _storage.write(_ANALOGUE_CLOCK, v);
  }

  set lastFeed(bool v) {
    _lastFeed = v;
    _storage.write(_LAST_FEED, v);
  }

  set notificationCount(int v) {
    if (v < 0) return;
    _notificationCount = v;
    _storage.write(_NOTIFICATION_COUNT, v);
  }

  set id0(int? v) {
    _id0 = v;
    v != null ? _storage.write(_ID_0, v) : _storage.remove(_ID_0);
  }

  set id1(int? v) {
    _id1 = v;
    v != null ? _storage.write(_ID_1, v) : _storage.remove(_ID_1);
  }

  set expiration0(int? v) {
    _expiration0 = v;
    v != null
        ? _storage.write(_EXPIRATION_0, v)
        : _storage.remove(_EXPIRATION_0);
  }

  set expiration1(int? v) {
    _expiration1 = v;
    v != null
        ? _storage.write(_EXPIRATION_1, v)
        : _storage.remove(_EXPIRATION_1);
  }

  set id(int? v) {
    if (_account == null) return;
    _account == 0 ? id0 = v : id1 = v;
  }

  set expiration(int? v) {
    if (_account == null) return;
    _account == 0 ? expiration0 = v : expiration1 = v;
  }
}

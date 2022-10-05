import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/theming.dart';
import 'package:path_provider/path_provider.dart';

// Local settings.
class Settings extends ChangeNotifier {
  Settings._(
    this._account,
    this._themeMode,
    this._theme,
    this._pureBlackDarkTheme,
    this._defaultHomeTab,
    this._defaultDiscoverType,
    this._defaultAnimeSort,
    this._defaultMangaSort,
    this._defaultDiscoverSort,
    this._imageQuality,
    this._confirmExit,
    this._leftHanded,
    this._analogueClock,
    this._inboxOnFeed,
    this._feedOnFollowing,
    this._compactDiscoverGrid,
    this._feedActivityFilters,
    this._lastNotificationId,
    this._id0,
    this._id1,
    this._expiration0,
    this._expiration1,
  );

  factory Settings._read() {
    return Settings._(
      _box.get(_ACCOUNT),
      ThemeMode.values[(_box.get(_THEME_MODE) ?? 0)],
      _box.get(_THEME),
      _box.get(_PURE_BLACK_DARK_THEME) ?? false,
      _box.get(_DEFAULT_HOME_TAB) ?? 0,
      DiscoverType.values[_box.get(_DEFAULT_DISCOVER_TYPE) ?? 0],
      EntrySort.values[_box.get(_DEFAULT_ANIME_SORT) ?? 0],
      EntrySort.values[_box.get(_DEFAULT_MANGA_SORT) ?? 0],
      MediaSort.values[
          _box.get(_DEFAULT_DISCOVER_SORT) ?? MediaSort.TRENDING_DESC.index],
      _box.get(_IMAGE_QUALITY) ?? 'large',
      _box.get(_CONFIRM_EXIT) ?? false,
      _box.get(_LEFT_HANDED) ?? false,
      _box.get(_ANALOGUE_CLOCK) ?? false,
      _box.get(_INBOX_ON_FEED) ?? true,
      _box.get(_FEED_ON_FOLLOWING) ?? false,
      _box.get(_COMPACT_DISCOVER_GRID) ?? false,
      _box.get(_FEED_ACTIVITY_FILTERS) ?? [0, 1, 2],
      _box.get(_LAST_NOTIFICATION_ID) ?? -1,
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
  static const _THEME = 'theme';
  static const _PURE_BLACK_DARK_THEME = 'pureBlackDarkTheme';
  static const _DEFAULT_HOME_TAB = 'defaultHomeTab';
  static const _DEFAULT_DISCOVER_TYPE = 'defaultExplorable';
  static const _DEFAULT_ANIME_SORT = 'defaultAnimeSort';
  static const _DEFAULT_MANGA_SORT = 'defaultMangaSort';
  static const _DEFAULT_DISCOVER_SORT = 'defaultExploreSort';
  static const _IMAGE_QUALITY = 'imageQuality';
  static const _CONFIRM_EXIT = 'confirmExit';
  static const _LEFT_HANDED = 'leftHanded';
  static const _ANALOGUE_CLOCK = 'analogueClock';
  static const _INBOX_ON_FEED = 'inboxOnFeed';
  static const _FEED_ON_FOLLOWING = 'feedOnFollowing';
  static const _COMPACT_DISCOVER_GRID = 'compactDiscoverGrid';
  static const _FEED_ACTIVITY_FILTERS = 'feedActivityFilters';
  static const _LAST_NOTIFICATION_ID = 'lastNotificationId';
  static const _ID_0 = 'id0';
  static const _ID_1 = 'id1';
  static const _EXPIRATION_0 = 'expiration0';
  static const _EXPIRATION_1 = 'expiration1';
  static const _ACCOUNT = 'account';

  static bool _didInit = false;

  // Should be called before use.
  static Future<void> init() async {
    if (_didInit) return;
    _didInit = true;

    WidgetsFlutterBinding.ensureInitialized();

    // Configure home directory if not in the browser.
    if (!kIsWeb) Hive.init((await getApplicationDocumentsDirectory()).path);

    await Hive.openBox(_SETTINGS);
    _it = Settings._read();
  }

  static Box get _box => Hive.box(_SETTINGS);

  int? _account;
  ThemeMode _themeMode;
  int? _theme;
  bool _pureBlackDarkTheme;
  int _defaultHomeTab;
  DiscoverType _defaultDiscoverType;
  EntrySort _defaultAnimeSort;
  EntrySort _defaultMangaSort;
  MediaSort _defaultDiscoverSort;
  String _imageQuality;
  bool _confirmExit;
  bool _leftHanded;
  bool _analogueClock;
  bool _inboxOnFeed;
  bool _feedOnFollowing;
  bool _compactDiscoverGrid;
  List<int> _feedActivityFilters;
  int _lastNotificationId;

  int? _id0;
  int? _id1;
  int? _expiration0;
  int? _expiration1;

  int? get selectedAccount => _account;
  ThemeMode get themeMode => _themeMode;
  int? get theme => _theme;
  bool get pureBlackDarkTheme => _pureBlackDarkTheme;
  int get defaultHomeTab => _defaultHomeTab;
  DiscoverType get defaultDiscoverType => _defaultDiscoverType;
  EntrySort get defaultAnimeSort => _defaultAnimeSort;
  EntrySort get defaultMangaSort => _defaultMangaSort;
  MediaSort get defaultDiscoverSort => _defaultDiscoverSort;
  String get imageQuality => _imageQuality;
  bool get confirmExit => _confirmExit;
  bool get leftHanded => _leftHanded;
  bool get analogueClock => _analogueClock;
  bool get inboxOnFeed => _inboxOnFeed;
  bool get feedOnFollowing => _feedOnFollowing;
  bool get compactDiscoverGrid => _compactDiscoverGrid;
  List<int> get feedActivityFilters => _feedActivityFilters;
  int get lastNotificationId => _lastNotificationId;

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
      _it.lastNotificationId = -1;
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
    _box.put(_THEME_MODE, v.index);
    notifyListeners();
  }

  set theme(int? v) {
    if (v == _theme) return;

    if (v == null) {
      _theme = null;
      _box.delete(_THEME);
      notifyListeners();
      return;
    }

    if (v < 0 || v >= colorSeeds.length) return;
    _theme = v;
    _box.put(_THEME, v);
    notifyListeners();
  }

  set pureBlackDarkTheme(bool v) {
    if (_pureBlackDarkTheme == v) return;
    _pureBlackDarkTheme = v;
    _box.put(_PURE_BLACK_DARK_THEME, v);
    notifyListeners();
  }

  set defaultHomeTab(int v) {
    if (v < 0 || v > 4) return;
    _defaultHomeTab = v;
    _box.put(_DEFAULT_HOME_TAB, v);
  }

  set defaultDiscoverType(DiscoverType v) {
    _defaultDiscoverType = v;
    _box.put(_DEFAULT_DISCOVER_TYPE, v.index);
  }

  set defaultAnimeSort(EntrySort v) {
    _defaultAnimeSort = v;
    _box.put(_DEFAULT_ANIME_SORT, v.index);
  }

  set defaultMangaSort(EntrySort v) {
    _defaultMangaSort = v;
    _box.put(_DEFAULT_MANGA_SORT, v.index);
  }

  set defaultDiscoverSort(MediaSort v) {
    _defaultDiscoverSort = v;
    _box.put(_DEFAULT_DISCOVER_SORT, v.index);
  }

  set imageQuality(String v) {
    if (v != 'extraLarge' && v != 'large' && v != 'medium') return;
    _imageQuality = v;
    _box.put(_IMAGE_QUALITY, v);
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

  set inboxOnFeed(bool v) {
    _inboxOnFeed = v;
    _box.put(_INBOX_ON_FEED, v);
  }

  set feedOnFollowing(bool v) {
    _feedOnFollowing = v;
    _box.put(_FEED_ON_FOLLOWING, v);
  }

  set compactDiscoverGrid(bool v) {
    _compactDiscoverGrid = v;
    _box.put(_COMPACT_DISCOVER_GRID, v);
  }

  set feedActivityFilters(List<int> v) {
    _feedActivityFilters = v;
    _box.put(_FEED_ACTIVITY_FILTERS, v);
  }

  set lastNotificationId(int v) {
    _lastNotificationId = v;
    v > -1
        ? _box.put(_LAST_NOTIFICATION_ID, v)
        : _box.delete(_LAST_NOTIFICATION_ID);
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

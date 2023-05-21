import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/activity/activities_providers.dart';
import 'package:otraku/discover/discover_providers.dart';
import 'package:otraku/utils/options.dart';

final homeProvider = ChangeNotifierProvider.autoDispose((ref) => HomeNotifier());

class HomeNotifier extends ChangeNotifier {
  int _homeTab = Options().defaultHomeTab;

  int get homeTab => _homeTab;

  set homeTab(int val) {
    if (_homeTab == val) return;
    _homeTab = val;
    notifyListeners();
  }

  /// The system schemes acquired asynchronously
  /// from [DynamicColorBuilder] are cached.
  ColorScheme? _systemLightScheme;
  ColorScheme? _systemDarkScheme;

  ColorScheme? getSystemScheme(bool isDark) => isDark ? _systemDarkScheme : _systemLightScheme;

  void setSystemSchemes(ColorScheme? l, ColorScheme? d) {
    _systemLightScheme = l;
    _systemDarkScheme = d;
  }

  /// The discover and feed tab are loaded lazily, when they are first opened.
  var _didLoadDiscover = false;
  var _didLoadFeed = false;

  bool get didLoadDiscover => _didLoadDiscover;
  bool get didLoadFeed => _didLoadFeed;

  void lazyLoadDiscover(WidgetRef ref) {
    if (_didLoadDiscover) return;
    _didLoadDiscover = true;
    discoverLoadMore(ref);
  }

  void lazyLoadFeed(WidgetRef ref) {
    if (_didLoadFeed) return;
    _didLoadFeed = true;
    ref.read(activitiesProvider(null).notifier).fetch();
  }

  /// In preview mode, user's collections first load only current media.
  /// The rest is loaded by a manual request from the user
  /// and thus the collection "expands".
  /// If preview mode is off, collections are auto-expanded
  /// and immediately load everything.
  var _didExpandAnimeCollection = !Options().animeCollectionPreview;
  var _didExpandMangaCollection = !Options().mangaCollectionPreview;

  bool didExpandCollection(bool ofAnime) => ofAnime ? _didExpandAnimeCollection : _didExpandMangaCollection;

  void expandCollection(bool ofAnime) {
    if (ofAnime) {
      if (_didExpandAnimeCollection) return;
      _didExpandAnimeCollection = true;
      notifyListeners();
    } else {
      if (_didExpandMangaCollection) return;
      _didExpandMangaCollection = true;
      notifyListeners();
    }
  }
}

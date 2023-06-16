import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/activity/activities_providers.dart';
import 'package:otraku/modules/discover/discover_providers.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/schedule/schedule_provider.dart';

final homeProvider =
    ChangeNotifierProvider.autoDispose((ref) => HomeNotifier());

class HomeNotifier extends ChangeNotifier {
  HomeTab _homeTab = Options().defaultHomeTab;

  HomeTab get homeTab => _homeTab;

  set homeTab(HomeTab val) {
    if (_homeTab == val) return;
    _homeTab = val;
    notifyListeners();
  }

  /// The system schemes acquired asynchronously
  /// from [DynamicColorBuilder] are cached.
  ColorScheme? _systemLightScheme;
  ColorScheme? _systemDarkScheme;

  ColorScheme? getSystemScheme(bool isDark) =>
      isDark ? _systemDarkScheme : _systemLightScheme;

  void setSystemSchemes(ColorScheme? l, ColorScheme? d) {
    _systemLightScheme = l;
    _systemDarkScheme = d;
  }

  /// The discover and feed tab are loaded lazily, when first opened.
  var _didLoadFeed = false;
  var _didLoadDiscover = false;
  var _didLoadSchedule = false;

  bool get didLoadFeed => _didLoadFeed;
  bool get didLoadDiscover => _didLoadDiscover;
  bool get didLoadSchedule => _didLoadSchedule;

  void lazyLoadTabs(WidgetRef ref) {
    if (_homeTab == HomeTab.feed && !_didLoadFeed) {
      _didLoadFeed = true;
      ref.read(activitiesProvider(null).notifier).fetch();
    }

    if (_homeTab == HomeTab.discover && !_didLoadDiscover) {
      _didLoadDiscover = true;
      discoverLoadMore(ref);
    }

    if (_homeTab == HomeTab.schedule && !_didLoadSchedule) {
      _didLoadSchedule = true;
      scheduleLoadMore(ref);
    }
  }

  /// In preview mode, user's collections first load only current media.
  /// The rest is loaded by a manual request from the user
  /// and thus the collection "expands".
  /// If preview mode is off, collections are auto-expanded
  /// and immediately load everything.
  var _didExpandAnimeCollection = !Options().animeCollectionPreview;
  var _didExpandMangaCollection = !Options().mangaCollectionPreview;

  bool didExpandCollection(bool ofAnime) =>
      ofAnime ? _didExpandAnimeCollection : _didExpandMangaCollection;

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

enum HomeTab {
  feed,
  anime,
  manga,
  discover,
  schedule,
  profile;

  String get title => switch (this) {
        feed => 'Feed',
        anime => 'Anime',
        manga => 'Manga',
        discover => 'Discover',
        schedule => 'Schedule',
        profile => 'Profile',
      };

  IconData get iconData => switch (this) {
        feed => Ionicons.file_tray_outline,
        anime => Ionicons.film_outline,
        manga => Ionicons.bookmark_outline,
        discover => Ionicons.compass_outline,
        schedule => Ionicons.calendar_clear_outline,
        profile => Ionicons.person_outline,
      };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/discover/discover_providers.dart';
import 'package:otraku/utils/options.dart';

final homeProvider =
    ChangeNotifierProvider.autoDispose((ref) => HomeNotifier());

class HomeNotifier extends ChangeNotifier {
  int _homeTab = Options().defaultHomeTab;
  bool _inboxOnFeed = Options().inboxOnFeed;

  /// The system schemes acquired asynchronously
  /// from [DynamicColorBuilder] are cached.
  ColorScheme? _systemLightScheme;
  ColorScheme? _systemDarkScheme;

  /// The discover and feed tab are loaded lazily.
  var _didLoadDiscover = false;
  var _didLoadFeed = false;

  int get homeTab => _homeTab;
  bool get inboxOnFeed => _inboxOnFeed;

  set homeTab(int val) {
    if (_homeTab == val) return;
    _homeTab = val;
    notifyListeners();
  }

  set inboxOnFeed(bool val) {
    if (_inboxOnFeed == val) return;
    _inboxOnFeed = val;
    Options().inboxOnFeed = val;
    notifyListeners();
  }

  ColorScheme? getSystemScheme(bool isDark) =>
      isDark ? _systemDarkScheme : _systemLightScheme;

  void setSystemSchemes(ColorScheme? l, ColorScheme? d) {
    _systemLightScheme = l;
    _systemDarkScheme = d;
  }

  /// Load the discover tab, if it hasn't been loaded.
  void lazyLoadDiscover(WidgetRef ref) {
    if (_didLoadDiscover) return;
    _didLoadDiscover = true;
    discoverLoadMore(ref);
  }

  /// Load the feed tab, if it hasn't been loaded.
  void lazyLoadFeed(WidgetRef ref) {
    if (_didLoadFeed) return;
    _didLoadFeed = true;
    ref.read(activitiesProvider(null).notifier).fetch();
  }
}

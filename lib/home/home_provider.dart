import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

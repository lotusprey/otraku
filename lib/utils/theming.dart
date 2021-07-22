import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/utils/config.dart';

class Theming with ChangeNotifier {
  // Storage keys.
  static const THEME_MODE = 'themeMode';
  static const LIGHT_THEME = 'theme1';
  static const DARK_THEME = 'theme2';

  static final it = Theming._();

  Theming._() {
    _mode = ThemeMode.values[(Config.storage.read(THEME_MODE) ?? 0)];
    _light = Themes.values[(Config.storage.read(LIGHT_THEME)) ?? 0];
    _dark = Themes.values[(Config.storage.read(DARK_THEME)) ?? 0];
    _setTheme();
  }

  late ThemeMode _mode;
  late Themes _light;
  late Themes _dark;
  late Themes _theme;

  ThemeMode get mode => _mode;
  Themes get light => _light;
  Themes get dark => _dark;
  Themes get theme => _theme;

  void setMode(int i) {
    if (i < 0 || i > ThemeMode.values.length || i == _mode.index) return;
    _mode = ThemeMode.values[i];
    refresh();
  }

  void setLight(int i) {
    if (i < 0 || i > Themes.values.length || i == _light.index) return;
    _light = Themes.values[i];
    refresh();
  }

  void setDark(int i) {
    if (i < 0 || i > Themes.values.length || i == _dark.index) return;
    _dark = Themes.values[i];
    refresh();
  }

  void _setTheme() {
    final platform = SchedulerBinding.instance?.window.platformBrightness;
    final isDark = _mode == ThemeMode.system
        ? platform == Brightness.dark
        : _mode == ThemeMode.dark;

    _theme = isDark ? _dark : _light;
    SystemChrome.setSystemUIOverlayStyle(_theme.overlayStyle);
  }

  void refresh() {
    _setTheme();
    notifyListeners();
  }
}

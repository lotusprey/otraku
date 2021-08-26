import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:otraku/models/theme_model.dart';
import 'package:otraku/utils/config.dart';

class Theming with ChangeNotifier {
  // Sizes.
  static const ICON_BIG = 25.0;
  static const ICON_SMALL = 20.0;
  static const FONT_BIG = 20.0;
  static const FONT_MEDIUM = 15.0;
  static const FONT_SMALL = 13.0;

  // Storage keys.
  static const _THEME_MODE = 'themeMode';
  static const _LIGHT_THEME = 'theme1';
  static const _DARK_THEME = 'theme2';
  // static const _CUSTOM_1 = 'customTheme1';
  // static const _CUSTOM_2 = 'customTheme2';

  static final it = Theming._();

  Theming._() {
    _mode = ThemeMode.values[(Config.storage.read(_THEME_MODE) ?? 0)];
    _light = Config.storage.read(_LIGHT_THEME) ?? 0;
    _dark = Config.storage.read(_DARK_THEME) ?? 0;
    _setTheme();
  }

  late ThemeModel _theme;
  late ThemeMode _mode;
  late int _light;
  late int _dark;

  ThemeModel get theme => _theme;
  ThemeMode get mode => _mode;
  int get light => _light;
  int get dark => _dark;

  set mode(ThemeMode val) {
    if (val == _mode) return;
    Config.storage.write(_THEME_MODE, val.index);
    _mode = val;
    refresh();
  }

  set light(int val) {
    if (val < 0 || val > _themes.length || val == _light) return;
    Config.storage.write(_LIGHT_THEME, val);
    _light = val;
    refresh();
  }

  set dark(int val) {
    if (val < 0 || val > _themes.length || val == _dark) return;
    Config.storage.write(_DARK_THEME, val);
    _dark = val;
    refresh();
  }

  void _setTheme() {
    final platform = SchedulerBinding.instance?.window.platformBrightness;
    final isDark = _mode == ThemeMode.system
        ? platform == Brightness.dark
        : _mode == ThemeMode.dark;

    _theme = _themes.values.elementAt(isDark ? _dark : _light);
    SystemChrome.setSystemUIOverlayStyle(_theme.overlayStyle);
  }

  void refresh() {
    _setTheme();
    notifyListeners();
  }

  static List<String> get names => _themes.keys.toList();

  static final _themes = {
    'Navy': ThemeModel(
      brightness: Brightness.dark,
      background: Color(0xFF0F171E),
      onBackground: Color(0xFFCAD5E2),
      surface: Color(0xFF1D2835),
      onSurface: Color(0xFFCAD5E2),
      primary: Color(0xFF56789F),
      secondary: Color(0xFF45A0F2),
      onSecondary: Color(0xFF0F171E),
      error: Color(0xFFD74761),
      onError: Color(0xFF0F171E),
    ),
    'Cyber': ThemeModel(
      brightness: Brightness.dark,
      background: Color(0xFF163B3B),
      onBackground: Color(0xFFFFFEFF),
      surface: Color(0xFF1A6157),
      onSurface: Color(0xFFFFFEFF),
      primary: Color(0xFF85D6C2),
      secondary: Color(0xFF00E4A3),
      onSecondary: Color(0xFF163B3B),
      error: Color(0xFFD87CAC),
      onError: Color(0xFF163B3B),
    ),
    'Night': ThemeModel(
      brightness: Brightness.dark,
      background: Color(0xFF08123A),
      onBackground: Color(0xFFEBFFFA),
      surface: Color(0xFF1E2964),
      onSurface: Color(0xFFEBFFFA),
      primary: Color(0xFF6B80DB),
      secondary: Color(0xFF41C0AA),
      onSecondary: Color(0xFF08123A),
      error: Color(0xFFF445AF),
      onError: Color(0xFF08123A),
    ),
    'Amethyst': ThemeModel(
      brightness: Brightness.dark,
      background: Color(0xFF1E1E3F),
      onBackground: Color(0xFFE8D9FC),
      surface: Color(0xFF2D2B55),
      onSurface: Color(0xFFE8D9FC),
      primary: Color(0xFFA7A0F8),
      secondary: Color(0xFFDFCD01),
      onSecondary: Color(0xFF1E1E3F),
      error: Color(0xFFF94E7E),
      onError: Color(0xFF1E1E3F),
    ),
    'Bee': ThemeModel(
      brightness: Brightness.dark,
      background: Color(0xFF000000),
      onBackground: Color(0xFFFFFFD6),
      surface: Color(0xFF141414),
      onSurface: Color(0xFFFFFFD6),
      primary: Color(0xFF999999),
      secondary: Color(0xFFFFDB00),
      onSecondary: Color(0xFF000000),
      error: Color(0xFFFF1F39),
      onError: Color(0xFF000000),
    ),
    'Frost': ThemeModel(
      brightness: Brightness.light,
      background: Color(0xFFE0EBF5),
      onBackground: Color(0xFF1B2937),
      surface: Color(0xFFFAFDFF),
      onSurface: Color(0xFF1B2937),
      primary: Color(0xFF3D5D7B),
      secondary: Color(0xFF54B2F1),
      onSecondary: Color(0xFFE0EBF5),
      error: Color(0xFFE32749),
      onError: Color(0xFFE0EBF5),
    ),
    // 'Custom #1': ThemeModel.read(_CUSTOM_1),
    // 'Custom #2': ThemeModel.read(_CUSTOM_2),
  };
}

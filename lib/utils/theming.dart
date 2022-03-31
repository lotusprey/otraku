import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:otraku/models/theme_model.dart';
import 'package:otraku/utils/settings.dart';

class Theming with ChangeNotifier {
  Theming._() {
    _setTheme();
  }

  factory Theming() => _it;

  static final _it = Theming._();

  late ThemeModel _theme;

  ThemeData get theme => _theme.themeData;

  void _setTheme() {
    final mode = Settings().themeMode;
    final light = Settings().lightTheme;
    final dark = Settings().darkTheme;

    final platform = SchedulerBinding.instance?.window.platformBrightness;
    final isDark = mode == ThemeMode.system
        ? platform == Brightness.dark
        : mode == ThemeMode.dark;

    _theme = _themes.values.elementAt(isDark ? dark : light);

    final overlayBrightness = _theme.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _theme.background,
      statusBarBrightness: _theme.brightness,
      statusBarIconBrightness: overlayBrightness,
      systemNavigationBarColor: _theme.background,
      systemNavigationBarIconBrightness: overlayBrightness,
    ));
  }

  void refresh() {
    _setTheme();
    notifyListeners();
  }

  /// Typically used for [DropDownFields].
  static Map<String, int> get themes =>
      Map.fromIterables(_themes.keys, List.generate(_themes.length, (i) => i));

  static get themeCount => _themes.length;

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
      primary: Color(0xFF4A7196),
      secondary: Color(0xFF1D99ED),
      onSecondary: Color(0xFFE0EBF5),
      error: Color(0xFFE32749),
      onError: Color(0xFFE0EBF5),
    ),
  };
}

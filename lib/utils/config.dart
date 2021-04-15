import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/helper_models/tile_model.dart';
import 'package:otraku/pages/home/home_page.dart';

// Holds constants and configurations that
// are utilised throughout the whole app.
class Config {
  static const MATERIAL_TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS = Radius.circular(10);
  static const BORDER_RADIUS = BorderRadius.all(RADIUS);
  static const PHYSICS = BouncingScrollPhysics();
  static const FADE_DURATION = Duration(milliseconds: 300);
  static const TAB_SWITCH_DURATION = Duration(milliseconds: 200);

  // Storage keys
  static const STARTUP_PAGE = 'startupPage';
  static const THEME_MODE = 'themeMode';
  static const LIGHT_THEME = 'theme1';
  static const DARK_THEME = 'theme2';
  static const FOLLOWING_FEED = 'feedMode';

  static final filter = ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  static final storage = GetStorage();
  static final _index =
      ValueNotifier<int>(storage.read(STARTUP_PAGE) ?? HomePage.ANIME_LIST);

  static ValueNotifier<int> get index => _index;
  static setIndex(final int val) {
    if (val > -1 && val < 5) _index.value = val;
  }

  static ThemeData get theme {
    final themeMode = storage.read(THEME_MODE) ?? 0;
    final key = themeMode == 0
        ? Get.isPlatformDarkMode
            ? DARK_THEME
            : LIGHT_THEME
        : themeMode == 1
            ? LIGHT_THEME
            : DARK_THEME;

    return Themes.values[storage.read(key) ?? 0].themeData;
  }

  static void updateTheme() => Get.changeTheme(theme);

  static const highTile = TileModel(
    maxWidth: 125,
    imgWHRatio: 0.65,
    textHeight: 40,
    fit: BoxFit.cover,
    needsBackground: true,
  );

  static const squareTile = TileModel(
    maxWidth: 125,
    imgWHRatio: 1,
    textHeight: 40,
    fit: BoxFit.contain,
    needsBackground: false,
  );
}

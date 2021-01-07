import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/tile_config.dart';
import 'package:otraku/pages/home_page.dart';

// Holds constants and configurations that
// are utilised throughout the whole app.
class Config extends GetxController {
  static const MATERIAL_TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS = Radius.circular(10);
  static const BORDER_RADIUS = BorderRadius.all(RADIUS);
  static const PHYSICS = BouncingScrollPhysics();
  static const FADE_DURATION = Duration(milliseconds: 300);

  // Storage keys
  static const STARTUP_PAGE = 'startupPage';
  static const THEME_MODE = 'themeMode';
  static const LIGHT_THEME = 'theme1';
  static const DARK_THEME = 'theme2';

  static final storage = GetStorage();
  static TileConfig _highTile;
  static TileConfig _squareTile;
  int _pageIndex = storage.read(STARTUP_PAGE);

  // The dependency should be put as soon as
  // possible, but with proper context, so
  // that the MediaQuery can be used.
  Config() {
    _pageIndex ??= HomePage.ANIME_LIST;

    double width = (Get.mediaQuery.size.width - 40) / 3;
    if (width > 150) width = 150;

    _highTile = TileConfig(
      width: width,
      imgHeight: width * 1.5,
      fullHeight: width * 1.5 + 45,
      fit: BoxFit.cover,
      needsBackground: true,
    );

    _squareTile = TileConfig(
      width: width,
      imgHeight: width,
      fullHeight: width + 40,
      fit: BoxFit.contain,
      needsBackground: false,
    );
  }

  get pageIndex => _pageIndex;

  set pageIndex(int index) {
    _pageIndex = index;
    update();
  }

  // The first time it is called should be before the
  // app initialisation. Whenever it is called, the
  // theme is updated to the current configuration.
  static void updateTheme() {
    final themeMode = storage.read(Config.THEME_MODE) ?? 0;
    if (themeMode == 0) {
      if (Get.isPlatformDarkMode) {
        Get.changeTheme(
          Themes.values[storage.read(Config.DARK_THEME) ?? 0].themeData,
        );
      } else {
        Get.changeTheme(
          Themes.values[storage.read(Config.LIGHT_THEME) ?? 0].themeData,
        );
      }
    } else if (themeMode == 1) {
      Get.changeTheme(
        Themes.values[storage.read(Config.LIGHT_THEME) ?? 0].themeData,
      );
    } else {
      Get.changeTheme(
        Themes.values[storage.read(Config.DARK_THEME) ?? 0].themeData,
      );
    }
  }

  static TileConfig get highTile => _highTile;

  static TileConfig get squareTile => _squareTile;
}

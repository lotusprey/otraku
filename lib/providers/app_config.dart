import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/pages/tab_manager.dart';

class AppConfig {
  static const CONTROL_HEADER_ICON_HEIGHT = 35.0;
  static const MATERIAL_TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS = Radius.circular(5);
  static const BORDER_RADIUS = BorderRadius.all(RADIUS);

  static const STARTUP_PAGE = 'startupPage';
  static const THEME = 'theme';

  static RxInt _pageIndex;
  static LargeTileConfig _largeTileConfig;
  static bool _hasInit = false;

  static void init(BuildContext context) {
    if (_hasInit) return;

    _pageIndex =
        (GetStorage().read(STARTUP_PAGE) as int ?? TabManager.ANIME_LIST).obs;

    final tileWidth = (Get.mediaQuery.size.width - 40) / 3;
    _largeTileConfig = LargeTileConfig(
      tileWHRatio: 0.5,
      tileWidth: tileWidth,
      tileHeight: tileWidth * 2,
      tileImgHeight: tileWidth * 1.5,
    );

    _hasInit = true;
  }

  static get pageIndex => _pageIndex;

  static set pageIndex(int index) => _pageIndex.value = index;

  static set initialPage(int index) {
    if (index >= 0 && index < 5) GetStorage()..write(STARTUP_PAGE, index);
  }

  static LargeTileConfig get tileConfig => _largeTileConfig;
}

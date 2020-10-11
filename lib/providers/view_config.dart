import 'package:flutter/material.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/pages/tab_manager.dart';

class ViewConfig {
  static const CONTROL_HEADER_ICON_HEIGHT = 35.0;
  static const MATERIAL_TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS = Radius.circular(5);
  static const BORDER_RADIUS = BorderRadius.all(RADIUS);

  static LargeTileConfiguration _largeTileConfiguration;
  static int initialPage = TabManager.ANIME_LIST;
  static bool _hasInit = false;

  static void init(BuildContext context) {
    if (_hasInit) return;

    double tileWHRatio = 0.5;
    double tileWidth = (MediaQuery.of(context).size.width - 40) / 3;
    double tileHeight = tileWidth * 2;
    double tileImgHeight = 0.75 * tileHeight;

    _largeTileConfiguration = LargeTileConfiguration(
      tileWHRatio: tileWHRatio,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      tileImgHeight: tileImgHeight,
    );

    _hasInit = true;
  }

  static LargeTileConfiguration get tileConfiguration {
    return _largeTileConfiguration;
  }
}

import 'package:flutter/material.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/pages/tab_manager.dart';

class ViewConfig with ChangeNotifier {
  static const PADDING = EdgeInsets.all(10);
  static int _pageIndex = TabManager.ANIME_LIST;
  static LargeTileConfiguration _largeTileConfiguration;

  void init(BuildContext context) {
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
  }

  int get pageIndex {
    return _pageIndex;
  }

  LargeTileConfiguration get tileConfiguration {
    return _largeTileConfiguration;
  }

  void switchPage(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}

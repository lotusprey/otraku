import 'package:flutter/material.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/pages/tab_manager.dart';

class ViewConfig with ChangeNotifier {
  static int _pageIndex = TabManager.ANIME_LIST;
  static double _topInset;
  static double _height;
  static LargeTileConfiguration _largeTileConfiguration;

  void init(BuildContext context) {
    _topInset = MediaQuery.of(context).padding.top;
    _height = MediaQuery.of(context).size.height;

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

  double get topInset {
    return _topInset;
  }

  double get height {
    return _height;
  }

  void switchPage(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}

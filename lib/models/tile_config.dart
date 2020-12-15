import 'package:flutter/material.dart';

class TileConfig {
  final double width;
  final double imgHeight;
  final double fullHeight;
  final BoxFit fit;
  final bool needsBackground;

  TileConfig({
    @required this.width,
    @required this.imgHeight,
    @required this.fullHeight,
    @required this.fit,
    @required this.needsBackground,
  });
}

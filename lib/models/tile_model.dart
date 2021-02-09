import 'package:flutter/material.dart';

class TileModel {
  final double maxWidth;
  final double imgWHRatio;
  final double textHeight;
  final BoxFit fit;
  final bool needsBackground;

  TileModel({
    @required this.maxWidth,
    @required this.imgWHRatio,
    @required this.textHeight,
    @required this.fit,
    @required this.needsBackground,
  });
}

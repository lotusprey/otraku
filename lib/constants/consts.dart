import 'dart:ui';

import 'package:flutter/material.dart';

// Constants utilised throughout the whole app.
abstract class Consts {
  // General.
  static const MATERIAL_TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS = Radius.circular(10);
  static const BORDER_RADIUS = BorderRadius.all(RADIUS);
  static const FADE_DURATION = Duration(milliseconds: 300);
  static const PHYSICS =
      AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
  static final filter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);

  // Layout sizes.
  static const OVERLAY_WIDE = 600.0;
  static const OVERLAY_TIGHT = 400.0;

  // Font sizes.
  static const FONT_BIG = 20.0;
  static const FONT_MEDIUM = 15.0;
  static const FONT_SMALL = 13.0;

  // Icon sizes.
  static const ICON_BIG = 25.0;
  static const ICON_SMALL = 20.0;
}

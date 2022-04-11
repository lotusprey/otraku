import 'dart:ui';

import 'package:flutter/material.dart';

// Constants utilised throughout the whole app.
abstract class Consts {
  // General.
  static const TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS_MIN = Radius.circular(10);
  static const RADIUS_MAX = Radius.circular(20);
  static const BORDER_RAD_MIN = BorderRadius.all(RADIUS_MIN);
  static const BORDER_RAD_MAX = BorderRadius.all(RADIUS_MAX);
  static const FADE_DURATION = Duration(milliseconds: 300);
  static const TRANSITION_DURATION = Duration(milliseconds: 200);
  static const PHYSICS =
      AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
  static final filter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);

  // Optimal height to width ratio for a media cover.
  static const COVER_HW_RATIO = 1.53;

  // Layout sizes.
  static const LAYOUT_BIG = 1000.0;
  static const LAYOUT_MEDIUM = 600.0;
  static const LAYOUT_SMALL = 400.0;

  // Font sizes.
  static const FONT_BIG = 20.0;
  static const FONT_MEDIUM = 15.0;
  static const FONT_SMALL = 13.0;

  // Icon sizes.
  static const ICON_BIG = 25.0;
  static const ICON_SMALL = 20.0;
}

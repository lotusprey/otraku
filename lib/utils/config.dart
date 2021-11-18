import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

// Holds constants and configurations utilised throughout the whole app.
abstract class Config {
  static const MATERIAL_TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS = Radius.circular(10);
  static const BORDER_RADIUS = BorderRadius.all(RADIUS);
  static const FADE_DURATION = Duration(milliseconds: 300);
  static const PHYSICS =
      AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  static final filter = ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  static final storage = GetStorage();
}

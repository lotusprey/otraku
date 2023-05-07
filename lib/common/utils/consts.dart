import 'dart:ui';

import 'package:flutter/material.dart';

// Constants utilised throughout the whole app.
abstract class Consts {
  // General.
  static const tapTargetSize = 48.0;
  static const padding = EdgeInsets.all(10);
  static const radiusMin = Radius.circular(10);
  static const radiusMax = Radius.circular(20);
  static const borderRadiusMin = BorderRadius.all(radiusMin);
  static const borderRadiusMax = BorderRadius.all(radiusMax);
  static const physics = AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(),
  );
  static final blurFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);

  // Optimal height to width ratio for a media cover.
  static const coverHtoWRatio = 1.53;

  // Layout sizes.
  static const layoutBig = 1000.0;
  static const layoutMedium = 600.0;

  // Font sizes.
  static const fontBig = 20.0;
  static const fontMedium = 15.0;
  static const fontSmall = 13.0;

  // Icon sizes.
  static const iconBig = 25.0;
  static const iconSmall = 20.0;
}

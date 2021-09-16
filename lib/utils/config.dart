import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/views/home_view.dart';

// Holds constants and configurations utilised throughout the whole app.
abstract class Config {
  // Storage keys.
  static const STARTUP_PAGE = 'startupPage';
  static const FOLLOWING_FEED = 'feedMode';
  static const LAST_NOTIFICATION_COUNT = 'lastNotificationCount';
  static const CLOCK_TYPE = '12hourClock';
  static const LEFT_HANDED = 'leftHanded';
  static const DEFAULT_EXPLORE = 'defaultExplore';
  static const CONFIRM_EXIT = 'confirmExit';

  // Constants.
  static const MATERIAL_TAP_TARGET_SIZE = 48.0;
  static const PADDING = EdgeInsets.all(10);
  static const RADIUS = Radius.circular(10);
  static const BORDER_RADIUS = BorderRadius.all(RADIUS);
  static const FADE_DURATION = Duration(milliseconds: 300);
  static const PHYSICS =
      AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  static final filter = ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  static final storage = GetStorage();

  static final homeNotifier =
      ValueNotifier<int>(storage.read(STARTUP_PAGE) ?? HomeView.ANIME_LIST);

  static int get homeIndex => homeNotifier.value;
  static set homeIndex(int i) {
    if (i > -1 && i < 5) homeNotifier.value = i;
  }
}

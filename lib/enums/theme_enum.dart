import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/controllers/config.dart';

enum Themes {
  light_blue,
  navy,
  cyber,
  night,
  amethyst,
}

extension Styles on Themes {
  static const double ICON_BIG = 35;
  static const double ICON_MEDIUM = 30;
  static const double ICON_SMALL = 25;
  static const double ICON_SMALLER = 20;

  static const double FONT_BIG = 25;
  static const double FONT_MEDIUM = 20;
  static const double FONT_SMALL = 15;
  static const double FONT_SMALLER = 13;

  static const _themes = {
    Themes.light_blue: {
      'background': Color(0xFFFFFEFF),
      'primary': Color(0xFFF4F5F6),
      'translucent': Color(0xBBFFFEFF),
      'accent': Color(0xFF54B2F1),
      'error': Color(0xFFE32749),
      'faded': Color(0xFF3D5D7B),
      'contrast': Color(0xFF1B2937),
      'brightness': Brightness.light,
    },
    Themes.navy: {
      'background': Color(0xFF0F171E),
      'primary': Color(0xFF1D2835),
      'translucent': Color(0xBB0F171E),
      'accent': Color(0xFF45A0F2),
      'error': Color(0xFFD74761),
      'faded': Color(0xFF56789F),
      'contrast': Color(0xFFCAD5E2),
      'brightness': Brightness.dark,
    },
    Themes.cyber: {
      'background': Color(0xFF163B3B),
      'primary': Color(0xFF1A6157),
      'translucent': Color(0xBB163B3B),
      'accent': Color(0xFF00E4A3),
      'error': Color(0xFFD87CAC),
      'faded': Color(0xFF85D6C2),
      'contrast': Color(0xFFFFFEFF),
      'brightness': Brightness.dark,
    },
    Themes.night: {
      'background': Color(0xFF08123A),
      'primary': Color(0xFF1E2964),
      'translucent': Color(0xBB08123A),
      'accent': Color(0xFF41C0AA),
      'error': Color(0xFFF445AF),
      'faded': Color(0xFF6B80DB),
      'contrast': Color(0xFFEBFFFA),
      'brightness': Brightness.dark,
    },
    Themes.amethyst: {
      'background': Color(0xFF1E1E3F),
      'primary': Color(0xFF2D2B55),
      'translucent': Color(0xBB1E1E3F),
      'accent': Color(0xFFDFCD01),
      'error': Color(0xFFF94E7E),
      'faded': Color(0xFFA7A0F8),
      'contrast': Color(0xFFE8D9FC),
      'brightness': Brightness.dark,
    },
  };

  ThemeData get themeData => _buildTheme(_themes[this]);
}

ThemeData _buildTheme(Map<String, dynamic> theme) {
  final brightness = theme['brightness'] == Brightness.dark
      ? Brightness.light
      : Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: theme['primary'],
    systemNavigationBarIconBrightness: brightness,
    statusBarColor: theme['background'],
    statusBarIconBrightness: brightness,
    statusBarBrightness: theme['brightness'],
  ));

  return ThemeData(
    fontFamily: 'Rubik',
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: theme['brightness'],
    backgroundColor: theme['background'],
    scaffoldBackgroundColor: theme['background'],
    primaryColor: theme['primary'],
    accentColor: theme['accent'],
    errorColor: theme['error'],
    cardColor: theme['translucent'],
    buttonColor: theme['accent'],
    dividerColor: theme['contrast'],
    disabledColor: theme['faded'],
    unselectedWidgetColor: theme['faded'],
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: theme['primary'],
      selectedItemColor: theme['accent'],
      unselectedItemColor: theme['faded'],
    ),
    iconTheme: IconThemeData(
      color: theme['faded'],
      size: Styles.ICON_MEDIUM,
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: Config.BORDER_RADIUS,
      ),
      buttonColor: theme['accent'],
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: Styles.FONT_BIG,
        color: theme['faded'],
        fontWeight: FontWeight.w500,
      ),
      headline2: TextStyle(
        fontSize: Styles.FONT_MEDIUM,
        color: theme['accent'],
        fontWeight: FontWeight.w500,
      ),
      headline3: TextStyle(
        fontSize: Styles.FONT_MEDIUM,
        color: theme['contrast'],
        fontWeight: FontWeight.w500,
      ),
      headline4: TextStyle(
        fontSize: Styles.FONT_MEDIUM,
        color: theme['faded'],
        fontWeight: FontWeight.w500,
      ),
      headline5: TextStyle(
        fontSize: Styles.FONT_SMALL,
        color: theme['accent'],
        fontWeight: FontWeight.w500,
      ),
      headline6: TextStyle(
        fontSize: Styles.FONT_SMALL,
        color: theme['contrast'],
        fontWeight: FontWeight.w500,
      ),
      subtitle1: TextStyle(
        fontSize: Styles.FONT_SMALL,
        color: theme['faded'],
      ),
      subtitle2: TextStyle(
        fontSize: Styles.FONT_SMALLER,
        color: theme['faded'],
        fontWeight: FontWeight.normal,
      ),
      bodyText1: TextStyle(
        fontSize: Styles.FONT_SMALL,
        color: theme['contrast'],
        fontWeight: FontWeight.normal,
      ),
      bodyText2: TextStyle(
        fontSize: Styles.FONT_SMALL,
        color: theme['accent'],
        fontWeight: FontWeight.normal,
      ),
      button: TextStyle(
        fontSize: Styles.FONT_MEDIUM,
        color: theme['background'],
      ),
    ),
  );
}

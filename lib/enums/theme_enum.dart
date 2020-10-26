import 'package:flutter/material.dart';

enum Themes {
  slate,
  amethyst,
  peach,
  mint,
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
    Themes.slate: {
      'background': Color(0xFF0F171E),
      'primary': Color(0xFF1D2835),
      'translucent': Color(0xBB0F171E),
      'accent': Color(0xFF45A0F2),
      'error': Color(0xFFD74761),
      'faded': Color(0xFF56789F),
      'contrast': Color(0xFFCAD5E2),
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
    Themes.peach: {
      'background': Color(0xFFFFEFEB),
      'primary': Color(0xFFFFCFC2),
      'translucent': Color(0xBBFFEFEB),
      'accent': Color(0xFFFF2F0A),
      'error': Color(0xFFBA1812),
      'faded': Color(0xFF754543),
      'contrast': Color(0xFF413939),
      'brightness': Brightness.light,
    },
    Themes.mint: {
      'background': Color(0xFF163B3B),
      'primary': Color(0xFF1A6157),
      'translucent': Color(0xBB163B3B),
      'accent': Color(0xFF00E4A3),
      'error': Color(0xFFD87CAC),
      'faded': Color(0xFF85D6C2),
      'contrast': Color(0xFFFFFEFF),
      'brightness': Brightness.light,
    },
  };

  ThemeData get themeData => _buildTheme(_themes[this]);
}

ThemeData _buildTheme(Map<String, dynamic> theme) {
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
      button: TextStyle(
        fontSize: Styles.FONT_MEDIUM,
        color: Colors.white,
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
      subtitle1: TextStyle(
        fontSize: Styles.FONT_SMALL,
        color: theme['faded'],
      ),
      subtitle2: TextStyle(
        fontSize: Styles.FONT_SMALLER,
        color: theme['faded'],
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

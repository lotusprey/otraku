import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/utils/config.dart';

enum Themes {
  navy,
  cyber,
  night,
  amethyst,
  bee,
  frost,
}

extension Style on Themes {
  static const ICON_BIG = 25.0;
  static const ICON_SMALL = 20.0;

  static const FONT_BIG = 20.0;
  static const FONT_MEDIUM = 15.0;
  static const FONT_SMALL = 13.0;

  ThemeData get themeData => _buildTheme(_themes[this]!);
}

const _themes = {
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
  Themes.bee: {
    'background': Color(0xFF000000),
    'primary': Color(0xFF141414),
    'translucent': Color(0xBB000000),
    'accent': Color(0xFFFFDB00),
    'error': Color(0xFFFF1F39),
    'faded': Color(0xFF999999),
    'contrast': Color(0xFFFFFFD6),
    'brightness': Brightness.dark,
  },
  Themes.frost: {
    'background': Color(0xFFFFFEFF),
    'primary': Color(0xFFF4F5F6),
    'translucent': Color(0xBBFFFEFF),
    'accent': Color(0xFF54B2F1),
    'error': Color(0xFFE32749),
    'faded': Color(0xFF3D5D7B),
    'contrast': Color(0xFF1B2937),
    'brightness': Brightness.light,
  },
};

ThemeData _buildTheme(Map<String, dynamic> theme) {
  final brightness = theme['brightness'] == Brightness.dark
      ? Brightness.light
      : Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: theme['background'],
    systemNavigationBarIconBrightness: brightness,
    statusBarColor: theme['background'],
    statusBarIconBrightness: brightness,
    statusBarBrightness: theme['brightness'],
  ));

  return ThemeData(
    fontFamily: 'Rubik',
    brightness: theme['brightness'],
    backgroundColor: theme['background'],
    scaffoldBackgroundColor: theme['background'],
    primaryColor: theme['primary'],
    accentColor: theme['accent'],
    errorColor: theme['error'],
    cardColor: theme['translucent'],
    dividerColor: theme['contrast'],
    disabledColor: theme['faded'],
    unselectedWidgetColor: theme['faded'],
    toggleableActiveColor: theme['accent'],
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(color: theme['faded'], size: Style.ICON_BIG),
    tooltipTheme: TooltipThemeData(
      padding: Config.PADDING,
      decoration: BoxDecoration(
        color: theme['primary'],
        borderRadius: Config.BORDER_RADIUS,
      ),
      textStyle: TextStyle(fontSize: Style.FONT_MEDIUM, color: theme['faded']),
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: Config.RADIUS,
      thumbColor: MaterialStateProperty.all(theme['faded']),
    ),
    sliderTheme: SliderThemeData(
      thumbColor: theme['accent'],
      overlayColor: (theme['accent'] as Color).withAlpha(20),
      activeTrackColor: theme['accent'],
      inactiveTrackColor: theme['primary'],
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(theme['accent']),
      overlayColor: MaterialStateProperty.all(
        (theme['accent'] as Color).withAlpha(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: theme['primary'],
      hintStyle: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['faded'],
        fontWeight: FontWeight.normal,
      ),
      border: const OutlineInputBorder(
        borderRadius: Config.BORDER_RADIUS,
        borderSide: BorderSide.none,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(TextStyle(
          fontSize: Style.FONT_MEDIUM,
        )),
        foregroundColor: MaterialStateProperty.all(theme['accent']),
        overlayColor: MaterialStateProperty.all(
          (theme['accent'] as Color).withAlpha(20),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(TextStyle(
          fontSize: Style.FONT_MEDIUM,
          fontWeight: FontWeight.w500,
        )),
        backgroundColor: MaterialStateProperty.all(theme['accent']),
        foregroundColor: MaterialStateProperty.all(theme['background']),
        overlayColor: MaterialStateProperty.all(
          (theme['accent'] as Color).withAlpha(20),
        ),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: Config.BORDER_RADIUS,
        )),
      ),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: Style.FONT_BIG,
        color: theme['accent'],
        fontWeight: FontWeight.w500,
      ),
      headline2: TextStyle(
        fontSize: Style.FONT_BIG,
        color: theme['contrast'],
        fontWeight: FontWeight.w500,
      ),
      headline3: TextStyle(
        fontSize: Style.FONT_BIG,
        color: theme['faded'],
        fontWeight: FontWeight.w500,
      ),
      headline4: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['accent'],
        fontWeight: FontWeight.w500,
      ),
      headline5: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['contrast'],
        fontWeight: FontWeight.w500,
      ),
      headline6: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['faded'],
        fontWeight: FontWeight.w500,
      ),
      bodyText1: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['contrast'],
        fontWeight: FontWeight.normal,
      ),
      bodyText2: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['accent'],
        fontWeight: FontWeight.normal,
      ),
      subtitle1: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['faded'],
      ),
      subtitle2: TextStyle(
        fontSize: Style.FONT_SMALL,
        color: theme['faded'],
        fontWeight: FontWeight.normal,
      ),
      button: TextStyle(
        fontSize: Style.FONT_MEDIUM,
        color: theme['background'],
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

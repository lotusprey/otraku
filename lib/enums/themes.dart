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

  Map<String, dynamic> get _theme => _themes[this]!;

  SystemUiOverlayStyle get overlayStyle {
    final theme = _theme;

    final brightness = theme['brightness'] == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return SystemUiOverlayStyle(
      systemNavigationBarColor: theme['background'],
      systemNavigationBarIconBrightness: brightness,
      statusBarColor: theme['background'],
      statusBarIconBrightness: brightness,
      statusBarBrightness: theme['brightness'],
    );
  }

  ThemeData get themeData {
    final theme = _theme;

    return ThemeData(
      fontFamily: 'Rubik',
      brightness: theme['brightness'],
      backgroundColor: theme['background'],
      scaffoldBackgroundColor: theme['background'],
      primaryColor: theme['foreground'],
      accentColor: theme['accent'],
      errorColor: theme['error'],
      cardColor: theme['translucent'],
      dividerColor: theme['contrast'],
      disabledColor: theme['faded'],
      unselectedWidgetColor: theme['faded'],
      toggleableActiveColor: theme['accent'],
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: theme['brightness'],
        surface: theme['foreground'],
        background: theme['background'],
        primary: theme['accent'],
        primaryVariant: theme['accent'],
        secondary: theme['error'],
        secondaryVariant: theme['error'],
        error: theme['error'],
        onSurface: theme['contrast'],
        onBackground: theme['contrast'],
        onPrimary: theme['background'],
        onSecondary: theme['background'],
        onError: theme['background'],
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme['accent'],
        selectionColor: theme['highlight'],
        selectionHandleColor: theme['accent'],
      ),
      dialogTheme: DialogTheme(
        elevation: 10,
        backgroundColor: theme['background'],
        shape: RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
        titleTextStyle: TextStyle(
          fontSize: Style.FONT_MEDIUM,
          color: theme['contrast'],
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(
          fontSize: Style.FONT_MEDIUM,
          color: theme['contrast'],
          fontWeight: FontWeight.normal,
        ),
      ),
      iconTheme: IconThemeData(color: theme['faded'], size: Style.ICON_BIG),
      tooltipTheme: TooltipThemeData(
        padding: Config.PADDING,
        decoration: BoxDecoration(
          color: theme['foreground'],
          borderRadius: Config.BORDER_RADIUS,
          boxShadow: [
            BoxShadow(color: theme['background'], blurRadius: 10),
          ],
        ),
        textStyle:
            TextStyle(fontSize: Style.FONT_MEDIUM, color: theme['faded']),
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: Config.RADIUS,
        thumbColor: MaterialStateProperty.all(theme['faded']),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: theme['accent'],
        overlayColor: theme['highlight'],
        activeTrackColor: theme['accent'],
        inactiveTrackColor: theme['foreground'],
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(theme['accent']),
        overlayColor: MaterialStateProperty.all(theme['highlight']),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: theme['foreground'],
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
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: Config.BORDER_RADIUS,
          )),
          foregroundColor: MaterialStateProperty.all(theme['accent']),
          overlayColor: MaterialStateProperty.all(theme['highlight']),
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
          overlayColor: MaterialStateProperty.all(theme['highlight']),
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
          color: theme['accent'],
          fontWeight: FontWeight.normal,
        ),
        bodyText2: TextStyle(
          fontSize: Style.FONT_MEDIUM,
          color: theme['contrast'],
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
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

const _themes = {
  Themes.navy: {
    'background': Color(0xFF0F171E),
    'translucent': Color(0xBB0F171E),
    'foreground': Color(0xFF1D2835),
    'highlight': Color(0x441D2835),
    'accent': Color(0xFF45A0F2),
    'error': Color(0xFFD74761),
    'faded': Color(0xFF56789F),
    'contrast': Color(0xFFCAD5E2),
    'brightness': Brightness.dark,
  },
  Themes.cyber: {
    'background': Color(0xFF163B3B),
    'translucent': Color(0xBB163B3B),
    'foreground': Color(0xFF1A6157),
    'highlight': Color(0x441A6157),
    'accent': Color(0xFF00E4A3),
    'error': Color(0xFFD87CAC),
    'faded': Color(0xFF85D6C2),
    'contrast': Color(0xFFFFFEFF),
    'brightness': Brightness.dark,
  },
  Themes.night: {
    'background': Color(0xFF08123A),
    'translucent': Color(0xBB08123A),
    'foreground': Color(0xFF1E2964),
    'highlight': Color(0x441E2964),
    'accent': Color(0xFF41C0AA),
    'error': Color(0xFFF445AF),
    'faded': Color(0xFF6B80DB),
    'contrast': Color(0xFFEBFFFA),
    'brightness': Brightness.dark,
  },
  Themes.amethyst: {
    'background': Color(0xFF1E1E3F),
    'translucent': Color(0xBB1E1E3F),
    'foreground': Color(0xFF2D2B55),
    'highlight': Color(0x442D2B55),
    'accent': Color(0xFFDFCD01),
    'error': Color(0xFFF94E7E),
    'faded': Color(0xFFA7A0F8),
    'contrast': Color(0xFFE8D9FC),
    'brightness': Brightness.dark,
  },
  Themes.bee: {
    'background': Color(0xFF000000),
    'translucent': Color(0xBB000000),
    'foreground': Color(0xFF141414),
    'highlight': Color(0x44141414),
    'accent': Color(0xFFFFDB00),
    'error': Color(0xFFFF1F39),
    'faded': Color(0xFF999999),
    'contrast': Color(0xFFFFFFD6),
    'brightness': Brightness.dark,
  },
  Themes.frost: {
    'background': Color(0xFFE0EBF5),
    'translucent': Color(0xBBE0EBF5),
    'foreground': Color(0xFFFAFDFF),
    'highlight': Color(0x44FAFDFF),
    'accent': Color(0xFF54B2F1),
    'error': Color(0xFFE32749),
    'faded': Color(0xFF3D5D7B),
    'contrast': Color(0xFF1B2937),
    'brightness': Brightness.light,
  },
};

import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

class ThemeModel {
  final Brightness brightness;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color error;
  final Color onError;

  Color get translucent => background.withAlpha(190);

  Color get highlight => surfaceVariant.withAlpha(100);

  ThemeData get themeData => ThemeData(
        fontFamily: 'Rubik',
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        cardColor: translucent,
        disabledColor: surfaceVariant,
        unselectedWidgetColor: surfaceVariant,
        toggleableActiveColor: primary,
        splashColor: highlight,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme(
          brightness: brightness,
          background: background,
          onBackground: onBackground,
          surface: surface,
          onSurface: onSurface,
          surfaceVariant: surfaceVariant,
          primary: primary,
          primaryContainer: primaryContainer,
          onPrimary: background,
          secondary: primary,
          onSecondary: onPrimary,
          error: error,
          onError: onError,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: primary,
          selectionColor: highlight,
          selectionHandleColor: primary,
        ),
        dialogTheme: DialogTheme(
          elevation: 10,
          backgroundColor: background,
          shape: const RoundedRectangleBorder(
            borderRadius: Consts.BORDER_RAD_MAX,
          ),
          titleTextStyle: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.w500,
          ),
          contentTextStyle: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.normal,
          ),
        ),
        tooltipTheme: TooltipThemeData(
          padding: Consts.PADDING,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: Consts.BORDER_RAD_MIN,
            boxShadow: [BoxShadow(color: background, blurRadius: 10)],
          ),
          textStyle: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: surfaceVariant,
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: Consts.RADIUS_MIN,
          thumbColor: MaterialStateProperty.all(surfaceVariant),
        ),
        sliderTheme: SliderThemeData(
          thumbColor: primary,
          overlayColor: highlight,
          activeTrackColor: primary,
          inactiveTrackColor: surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: surface,
          hintStyle: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          border: const OutlineInputBorder(
            borderRadius: Consts.BORDER_RAD_MIN,
            borderSide: BorderSide.none,
          ),
        ),
        iconTheme: IconThemeData(color: surfaceVariant, size: Consts.ICON_BIG),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: Consts.FONT_MEDIUM,
              fontWeight: FontWeight.w500,
            )),
            backgroundColor: MaterialStateProperty.all(primary),
            foregroundColor: MaterialStateProperty.all(background),
            overlayColor: MaterialStateProperty.all(highlight),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
              borderRadius: Consts.BORDER_RAD_MIN,
            )),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: Consts.FONT_MEDIUM,
            )),
            foregroundColor: MaterialStateProperty.all(primary),
            overlayColor: MaterialStateProperty.all(highlight),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
              borderRadius: Consts.BORDER_RAD_MIN,
            )),
          ),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: Consts.FONT_BIG,
            color: onBackground,
            fontWeight: FontWeight.w500,
          ),
          headline2: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.w500,
          ),
          headline3: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: surfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          headline4: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          bodyText1: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: primary,
            fontWeight: FontWeight.normal,
          ),
          bodyText2: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.normal,
          ),
          subtitle1: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          subtitle2: TextStyle(
            fontSize: Consts.FONT_SMALL,
            color: surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          button: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: background,
            fontWeight: FontWeight.normal,
          ),
        ),
      );

  const ThemeModel._({
    required this.brightness,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.error,
    required this.onError,
  });

  factory ThemeModel({
    required Brightness brightness,
    required Color background,
    required Color onBackground,
    required Color surface,
    required Color onSurface,
    required Color surfaceVariant,
    required Color primary,
    required Color onPrimary,
    required Color error,
    required Color onError,
  }) {
    final hsl = HSLColor.fromColor(primary);
    final primaryContainer = hsl.lightness < 0.5
        ? hsl.withLightness(hsl.lightness + 0.1).toColor()
        : hsl.withLightness(hsl.lightness - 0.1).toColor();

    return ThemeModel._(
      brightness: brightness,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      error: error,
      onError: onError,
    );
  }
}

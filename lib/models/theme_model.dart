import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

class ThemeModel {
  final Brightness brightness;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color secondaryVariant;
  final Color onSecondary;
  final Color error;
  final Color onError;

  Color get translucent => background.withAlpha(190);

  Color get highlight => primary.withAlpha(100);

  ThemeData get themeData => ThemeData(
        fontFamily: 'Rubik',
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        cardColor: translucent,
        disabledColor: primary,
        unselectedWidgetColor: primary,
        toggleableActiveColor: secondary,
        splashColor: highlight,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme(
          brightness: brightness,
          background: background,
          onBackground: onBackground,
          surface: surface,
          onSurface: onSurface,
          primary: primary,
          primaryContainer: primaryVariant,
          onPrimary: background,
          secondary: secondary,
          secondaryContainer: secondaryVariant,
          onSecondary: onSecondary,
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
          cursorColor: secondary,
          selectionColor: highlight,
          selectionHandleColor: secondary,
        ),
        dialogTheme: DialogTheme(
          elevation: 10,
          backgroundColor: surface,
          shape: const RoundedRectangleBorder(
            borderRadius: Consts.BORDER_RAD_MIN,
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
          textStyle: TextStyle(fontSize: Consts.FONT_MEDIUM, color: primary),
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: Consts.RADIUS_MIN,
          thumbColor: MaterialStateProperty.all(primary),
        ),
        sliderTheme: SliderThemeData(
          thumbColor: secondary,
          overlayColor: highlight,
          activeTrackColor: secondary,
          inactiveTrackColor: surface,
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all(secondary),
          overlayColor: MaterialStateProperty.all(highlight),
        ),
        switchTheme: SwitchThemeData(
          trackColor: MaterialStateProperty.resolveWith(
            (states) =>
                states.contains(MaterialState.selected) ? secondary : primary,
          ),
          thumbColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? secondaryVariant
                : primaryVariant,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: surface,
          hintStyle: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: primary,
            fontWeight: FontWeight.normal,
          ),
          border: const OutlineInputBorder(
            borderRadius: Consts.BORDER_RAD_MIN,
            borderSide: BorderSide.none,
          ),
        ),
        iconTheme: IconThemeData(color: primary, size: Consts.ICON_BIG),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: Consts.FONT_MEDIUM,
              fontWeight: FontWeight.w500,
            )),
            backgroundColor: MaterialStateProperty.all(secondary),
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
            foregroundColor: MaterialStateProperty.all(secondary),
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
            color: primary,
            fontWeight: FontWeight.w500,
          ),
          headline4: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: primary,
            fontWeight: FontWeight.normal,
          ),
          bodyText1: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: secondary,
            fontWeight: FontWeight.normal,
          ),
          bodyText2: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.normal,
          ),
          subtitle1: TextStyle(
            fontSize: Consts.FONT_MEDIUM,
            color: primary,
            fontWeight: FontWeight.normal,
          ),
          subtitle2: TextStyle(
            fontSize: Consts.FONT_SMALL,
            color: primary,
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
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.secondaryVariant,
    required this.onSecondary,
    required this.error,
    required this.onError,
  });

  factory ThemeModel({
    required Brightness brightness,
    required Color background,
    required Color onBackground,
    required Color surface,
    required Color onSurface,
    required Color primary,
    required Color secondary,
    required Color onSecondary,
    required Color error,
    required Color onError,
  }) {
    HSLColor hsl = HSLColor.fromColor(primary);
    final primaryVariant = hsl.lightness < 0.1
        ? primary
        : hsl.withLightness(hsl.lightness - 0.1).toColor();

    hsl = HSLColor.fromColor(secondary);
    final secondaryVariant = hsl.lightness < 0.1
        ? secondary
        : hsl.withLightness(hsl.lightness - 0.1).toColor();

    return ThemeModel._(
      brightness: brightness,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      primaryVariant: primaryVariant,
      secondary: secondary,
      secondaryVariant: secondaryVariant,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
    );
  }
}

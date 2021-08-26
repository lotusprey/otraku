import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/theming.dart';

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

  SystemUiOverlayStyle get overlayStyle {
    final overlayBrightness =
        brightness == Brightness.dark ? Brightness.light : Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: background,
      statusBarBrightness: brightness,
      statusBarIconBrightness: overlayBrightness,
      systemNavigationBarColor: background,
      systemNavigationBarIconBrightness: overlayBrightness,
    );
  }

  ThemeData get themeData => ThemeData(
        fontFamily: 'Rubik',
        brightness: brightness,
        scaffoldBackgroundColor: background,
        cardColor: translucent,
        disabledColor: primary,
        unselectedWidgetColor: primary,
        toggleableActiveColor: secondary,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme(
          brightness: brightness,
          background: background,
          onBackground: onBackground,
          surface: surface,
          onSurface: onSurface,
          primary: primary,
          primaryVariant: primaryVariant,
          onPrimary: background,
          secondary: secondary,
          secondaryVariant: secondaryVariant,
          onSecondary: onSecondary,
          error: error,
          onError: onError,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: secondary,
          selectionColor: highlight,
          selectionHandleColor: secondary,
        ),
        dialogTheme: DialogTheme(
          elevation: 10,
          backgroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
          titleTextStyle: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.w500,
          ),
          contentTextStyle: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.normal,
          ),
        ),
        iconTheme: IconThemeData(color: primary, size: Theming.ICON_BIG),
        tooltipTheme: TooltipThemeData(
          padding: Config.PADDING,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: Config.BORDER_RADIUS,
            boxShadow: [BoxShadow(color: background, blurRadius: 10)],
          ),
          textStyle: TextStyle(fontSize: Theming.FONT_MEDIUM, color: primary),
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: Config.RADIUS,
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
            fontSize: Theming.FONT_MEDIUM,
            color: primary,
            fontWeight: FontWeight.normal,
          ),
          border: const OutlineInputBorder(
            borderRadius: Config.BORDER_RADIUS,
            borderSide: BorderSide.none,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: Theming.FONT_MEDIUM,
            )),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
              borderRadius: Config.BORDER_RADIUS,
            )),
            foregroundColor: MaterialStateProperty.all(secondary),
            overlayColor: MaterialStateProperty.all(highlight),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: Theming.FONT_MEDIUM,
              fontWeight: FontWeight.w500,
            )),
            backgroundColor: MaterialStateProperty.all(secondary),
            foregroundColor: MaterialStateProperty.all(background),
            overlayColor: MaterialStateProperty.all(highlight),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
              borderRadius: Config.BORDER_RADIUS,
            )),
          ),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: Theming.FONT_BIG,
            color: secondary,
            fontWeight: FontWeight.w500,
          ),
          headline2: TextStyle(
            fontSize: Theming.FONT_BIG,
            color: onBackground,
            fontWeight: FontWeight.w500,
          ),
          headline3: TextStyle(
            fontSize: Theming.FONT_BIG,
            color: primary,
            fontWeight: FontWeight.w500,
          ),
          headline4: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: secondary,
            fontWeight: FontWeight.w500,
          ),
          headline5: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.w500,
          ),
          headline6: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: primary,
            fontWeight: FontWeight.w500,
          ),
          bodyText1: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: secondary,
            fontWeight: FontWeight.normal,
          ),
          bodyText2: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: onBackground,
            fontWeight: FontWeight.normal,
          ),
          subtitle1: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: primary,
          ),
          subtitle2: TextStyle(
            fontSize: Theming.FONT_SMALL,
            color: primary,
            fontWeight: FontWeight.normal,
          ),
          button: TextStyle(
            fontSize: Theming.FONT_MEDIUM,
            color: background,
            fontWeight: FontWeight.normal,
          ),
        ),
      );

  ThemeModel._({
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

  factory ThemeModel.read(String key) {
    final Map<String, dynamic> map = Config.storage.read(key) ?? {};

    return ThemeModel(
      brightness: map['brightness'] ?? Brightness.dark,
      background: map['background'] ?? Color(0xFF0F171E),
      onBackground: map['onBackground'] ?? Color(0xFFCAD5E2),
      surface: map['surface'] ?? Color(0xFF1D2835),
      onSurface: map['onSurface'] ?? Color(0xFFCAD5E2),
      primary: map['primary'] ?? Color(0xFF56789F),
      secondary: map['secondary'] ?? Color(0xFF45A0F2),
      onSecondary: map['onSecondary'] ?? Color(0xFF0F171E),
      error: map['error'] ?? Color(0xFFD74761),
      onError: map['onError'] ?? Color(0xFF0F171E),
    );
  }
}

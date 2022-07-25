import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';

class Theming with ChangeNotifier {
  Theming._() {
    refresh();
  }

  factory Theming() => _it;

  static final _it = Theming._();

  late ThemeData _data;

  ThemeData get data => _data;

  /// Update [_data] based on the current app theme settings
  /// and the device theme. Update the [SystemChrome].
  void refresh() {
    final mode = Settings().themeMode;
    final light = Settings().lightTheme;
    final dark = Settings().darkTheme;

    final platform = SchedulerBinding.instance.window.platformBrightness;
    final isDark = mode == ThemeMode.system
        ? platform == Brightness.dark
        : mode == ThemeMode.dark;

    _data = _createTheme(schemes.values.elementAt(isDark ? dark : light));

    final overlayBrightness = _data.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _data.colorScheme.background,
      statusBarBrightness: _data.colorScheme.brightness,
      statusBarIconBrightness: overlayBrightness,
      systemNavigationBarColor: _data.colorScheme.background,
      systemNavigationBarIconBrightness: overlayBrightness,
    ));

    notifyListeners();
  }

  /// Create [ThemeData] based on a [ColorScheme].
  ThemeData _createTheme(ColorScheme scheme) => ThemeData(
        useMaterial3: true,
        fontFamily: 'Rubik',
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.background,
        cardColor: scheme.background.withAlpha(190),
        disabledColor: scheme.surfaceVariant,
        unselectedWidgetColor: scheme.surfaceVariant,
        toggleableActiveColor: scheme.primary,
        splashColor: scheme.onBackground.withAlpha(20),
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        iconTheme: IconThemeData(
          color: scheme.surfaceVariant,
          size: Consts.iconBig,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: scheme.primary,
            onPrimary: scheme.onPrimary,
            textStyle: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        typography: Typography.material2014(),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: Consts.fontBig,
            color: scheme.onBackground,
            fontWeight: FontWeight.w500,
          ),
          headline2: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.onBackground,
            fontWeight: FontWeight.w500,
          ),
          headline3: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.surfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          headline4: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          bodyText1: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.primary,
            fontWeight: FontWeight.normal,
          ),
          bodyText2: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.onBackground,
            fontWeight: FontWeight.normal,
            height: null,
          ),
          subtitle1: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          subtitle2: TextStyle(
            fontSize: Consts.fontSmall,
            color: scheme.surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          button: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.background,
            fontWeight: FontWeight.normal,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: scheme.primary,
          selectionHandleColor: scheme.primary,
          selectionColor: scheme.primary.withAlpha(50),
        ),
        dialogTheme: DialogTheme(
          elevation: 10,
          backgroundColor: scheme.background,
          shape: const RoundedRectangleBorder(
            borderRadius: Consts.borderRadiusMax,
          ),
          titleTextStyle: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.onBackground,
            fontWeight: FontWeight.w500,
          ),
          contentTextStyle: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.onBackground,
            fontWeight: FontWeight.normal,
          ),
        ),
        tooltipTheme: TooltipThemeData(
          padding: Consts.padding,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: Consts.borderRadiusMin,
            boxShadow: [BoxShadow(color: scheme.background, blurRadius: 10)],
          ),
          textStyle: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.onSurface,
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: Consts.radiusMin,
          thumbColor: MaterialStateProperty.all(scheme.surfaceVariant),
        ),
        sliderTheme: SliderThemeData(
          thumbColor: scheme.primary,
          activeTrackColor: scheme.primary,
          inactiveTrackColor: scheme.surface,
          overlayColor: scheme.surface.withAlpha(50),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: scheme.surface,
          hintStyle: TextStyle(
            fontSize: Consts.fontMedium,
            color: scheme.surfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          border: const OutlineInputBorder(
            borderRadius: Consts.borderRadiusMax,
            borderSide: BorderSide.none,
          ),
        ),
      );

  // Built in colour schemes.
  static const schemes = {
    'Navy': ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xFF0D161E),
      onBackground: Color(0xFFC7DAEC),
      surface: Color(0xFF182531),
      onSurface: Color(0xFFC7DAEC),
      surfaceVariant: Color(0xFF3F6887),
      primary: Color(0xFF45A0F2),
      primaryContainer: Color(0xFF7bbcf4),
      onPrimary: Color(0xFF0D161E),
      secondary: Color(0xFF40C551),
      secondaryContainer: Color(0xFF92dd9c),
      onSecondary: Color(0xFF0D161E),
      error: Color(0xFFD74761),
      errorContainer: Color(0xFFe58a9b),
      onError: Color(0xFF0D161E),
    ),
    'Mint': ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xFF0A1E1E),
      onBackground: Color(0xFFC2E2E2),
      surface: Color(0xFF153131),
      onSurface: Color(0xFFC2E2E2),
      surfaceVariant: Color(0xFF3E7B7B),
      primary: Color(0xFF2AB8B8),
      primaryContainer: Color(0xFF59D9D9),
      onPrimary: Color(0xFF0A1E1E),
      secondary: Color(0xFFAB4EB5),
      secondaryContainer: Color(0xFFC17EC9),
      onSecondary: Color(0xFF0A1E1E),
      error: Color(0xFFE1323B),
      errorContainer: Color(0xFFE75F66),
      onError: Color(0xFF0A1E1E),
    ),
    'Amethyst': ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xFF131329),
      onBackground: Color(0xFFBBBBE1),
      surface: Color(0xFF20203B),
      onSurface: Color(0xFFBBBBE1),
      surfaceVariant: Color(0xFF555593),
      primary: Color(0xFFDFCD01),
      primaryContainer: Color(0xFFFEEF48),
      onPrimary: Color(0xFF131329),
      secondary: Color(0xFF3AC77E),
      secondaryContainer: Color(0xFF80DBAC),
      onSecondary: Color(0xFF131329),
      error: Color(0xFFD32E28),
      errorContainer: Color(0xFFE26965),
      onError: Color(0xFF131329),
    ),
    'Bee': ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xFF0E0E0E),
      onBackground: Color(0xFFFFFFFF),
      surface: Color(0xFF1D1D1D),
      onSurface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFC6C6C6),
      primary: Color(0xFFFABF0E),
      primaryContainer: Color(0xFFFBCF4B),
      onPrimary: Color(0xFF0E0E0E),
      secondary: Color(0xFF266AE9),
      secondaryContainer: Color(0xFF588DEE),
      onSecondary: Color(0xFF0E0E0E),
      error: Color(0xFFE93814),
      errorContainer: Color(0xFFEF6043),
      onError: Color(0xFF0E0E0E),
    ),
    'Frost': ColorScheme(
      brightness: Brightness.light,
      background: Color(0xFFE3F2FF),
      onBackground: Color(0xFF0D1923),
      surface: Color(0xFFC7E0F7),
      onSurface: Color(0xFF0D1923),
      surfaceVariant: Color(0xFF39546A),
      primary: Color(0xFF258EE4),
      primaryContainer: Color(0xFF7FBDF0),
      onPrimary: Color(0xFFE3F2FF),
      secondary: Color(0xFF34B04F),
      secondaryContainer: Color(0xFF72D587),
      onSecondary: Color(0xFFE3F2FF),
      error: Color(0xFFE32749),
      errorContainer: Color(0xFFE84A67),
      onError: Color(0xFFE3F2FF),
    ),
    'Rose': ColorScheme(
      brightness: Brightness.light,
      background: Color(0xFFFFEDFE),
      onBackground: Color(0xFF1E101E),
      surface: Color(0xFFFFD6FC),
      onSurface: Color(0xFF1E101E),
      surfaceVariant: Color(0xFF966B93),
      primary: Color(0xFFED5AED),
      primaryContainer: Color(0xFFF17EF1),
      onPrimary: Color(0xFFFFEDFE),
      secondary: Color(0xFF924ADF),
      secondaryContainer: Color(0xFFAB74E7),
      onSecondary: Color(0xFFFFEDFE),
      error: Color(0xFFD11C1C),
      errorContainer: Color(0xFFE74B4B),
      onError: Color(0xFFFFEDFE),
    ),
    'Lavender': ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xFF1D1329),
      onBackground: Color(0xFFCFBBE1),
      surface: Color(0xFF2D203B),
      onSurface: Color(0xFFCDBBE1),
      surfaceVariant: Color(0xFF5C5C99),
      primary: Color(0xFFB4ABF5),
      primaryContainer: Color(0xFF614DC4),
      onPrimary: Color(0xFF0E0E0E),
      secondary: Color(0xFF3AC77E),
      secondaryContainer: Color(0xFF80DBAC),
      onSecondary: Color(0xFF131329),
      error: Color(0xFFD74761),
      errorContainer: Color(0xFFe58a9b),
      onError: Color(0xFF0D161E),
    ),
  };
}

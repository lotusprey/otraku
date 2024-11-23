import 'dart:ui';

import 'package:flutter/material.dart';

enum ThemeBase {
  navy('Navy', Color(0xFF45A0F2)),
  mint('Mint', Color(0xFF2AB8B8)),
  lavender('Lavender', Color(0xFFB4ABF5)),
  caramel('Caramel', Color(0xFFF78204)),
  forest('Forest', Color(0xFF00FFA9)),
  wine('Wine', Color(0xFF894771)),
  mustard('Mustard', Color(0xFFFFBF02));

  const ThemeBase(this.title, this.seed);

  final String title;
  final Color seed;
}

class Theming {
  static const windowWidthMedium = 600.0;
  static const windowWidthLarge = 840.0;

  static const offset = 10.0;
  static const minTapTarget = 48.0;
  static const normalTapTarget = 56.0;
  static const coverHtoWRatio = 1.53;

  static const fontBig = 20.0;
  static const fontMedium = 15.0;
  static const fontSmall = 13.0;

  static const iconBig = 25.0;
  static const iconSmall = 20.0;

  static const paddingAll = EdgeInsets.all(offset);
  static const radiusSmall = Radius.circular(10);
  static const radiusBig = Radius.circular(20);
  static const borderRadiusSmall = BorderRadius.all(radiusSmall);
  static const borderRadiusBig = BorderRadius.all(radiusBig);
  static final blurFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);
  static const bouncyPhysics = AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(),
  );

  static ThemeData schemeToThemeData(ColorScheme scheme) => ThemeData(
        fontFamily: 'Rubik',
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        disabledColor: scheme.surface,
        unselectedWidgetColor: scheme.surface,
        splashColor: scheme.onSurface.withAlpha(20),
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        cardTheme: const CardTheme(margin: EdgeInsets.all(0)),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: iconBig),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: scheme.surface.withAlpha(190),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
        navigationRailTheme: const NavigationRailThemeData(
          labelType: NavigationRailLabelType.all,
          groupAlignment: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        chipTheme: ChipThemeData(
          labelStyle: TextStyle(
            color: scheme.onSecondaryContainer,
            fontWeight: FontWeight.normal,
          ),
        ),
        segmentedButtonTheme: const SegmentedButtonThemeData(
          style: ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: offset),
        ),
        typography: Typography.material2014(),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: fontBig,
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          titleMedium: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurface,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurface,
            fontWeight: FontWeight.normal,
          ),
          labelLarge: TextStyle(
            fontSize: fontMedium,
            color: scheme.primary,
            fontWeight: FontWeight.normal,
          ),
          labelMedium: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          labelSmall: TextStyle(
            fontSize: fontSmall,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: scheme.primary,
          selectionHandleColor: scheme.primary,
          selectionColor: scheme.primary.withAlpha(50),
        ),
        dividerTheme: const DividerThemeData(thickness: 1),
        dialogTheme: DialogTheme(
          backgroundColor: scheme.surface,
          titleTextStyle: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          contentTextStyle: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurface,
            fontWeight: FontWeight.normal,
          ),
        ),
        tooltipTheme: TooltipThemeData(
          padding: paddingAll,
          textStyle: TextStyle(color: scheme.onSurfaceVariant),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: borderRadiusSmall,
            boxShadow: [BoxShadow(color: scheme.surface, blurRadius: 10)],
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          interactive: true,
          radius: radiusSmall,
          thickness: WidgetStateProperty.all(5),
          thumbColor: WidgetStateProperty.all(scheme.primary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          hintStyle: TextStyle(
            fontSize: fontMedium,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
          border: const OutlineInputBorder(
            borderRadius: borderRadiusBig,
            borderSide: BorderSide.none,
          ),
        ),
      );
}

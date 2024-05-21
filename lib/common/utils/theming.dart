import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';

const colorSeeds = {
  'Navy': Color(0xFF45A0F2),
  'Mint': Color(0xFF2AB8B8),
  'Lavender': Color(0xFFB4ABF5),
  'Caramel': Color(0xFFF78204),
  'Forest': Color(0xFF00FFA9),
  'Wine': Color(0xFF894771),
  'Mustard': Color(0xFFFFBF02),
};

ThemeData themeDataFrom(ColorScheme scheme) => ThemeData(
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
      iconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: Consts.iconBig,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withAlpha(190),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      typography: Typography.material2014(),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: Consts.fontBig,
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.onSurface,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.onSurface,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.primary,
          fontWeight: FontWeight.normal,
        ),
        labelMedium: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.normal,
        ),
        labelSmall: TextStyle(
          fontSize: Consts.fontSmall,
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
          fontSize: Consts.fontMedium,
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.onSurface,
          fontWeight: FontWeight.normal,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        padding: Consts.padding,
        textStyle: TextStyle(color: scheme.onSurfaceVariant),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: Consts.borderRadiusMin,
          boxShadow: [BoxShadow(color: scheme.surface, blurRadius: 10)],
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        interactive: true,
        radius: Consts.radiusMin,
        thickness: WidgetStateProperty.all(5),
        thumbColor: WidgetStateProperty.all(scheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        hintStyle: TextStyle(
          fontSize: Consts.fontMedium,
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.normal,
        ),
        border: const OutlineInputBorder(
          borderRadius: Consts.borderRadiusMax,
          borderSide: BorderSide.none,
        ),
      ),
    );

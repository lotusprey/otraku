import 'dart:ui';

import 'package:flutter/material.dart';

enum FormFactor { phone, tablet }

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

class Theming extends ThemeExtension<Theming> {
  const Theming({required this.formFactor, required this.rightButtonOrientation});

  /// Pages should adapt their layouts, in consideration of the [formFactor].
  final FormFactor formFactor;

  /// Determines whether FAB and prominent buttons should be on the right side,
  /// with lest important buttons on the left.
  /// This makes core actions more accessible.
  final bool rightButtonOrientation;

  static Theming of(BuildContext context) =>
      Theme.of(context).extension<Theming>() ??
      const Theming(formFactor: .phone, rightButtonOrientation: true);

  @override
  ThemeExtension<Theming> copyWith({FormFactor? formFactor, bool? rightButtonOrientation}) =>
      Theming(
        formFactor: formFactor ?? this.formFactor,
        rightButtonOrientation: rightButtonOrientation ?? this.rightButtonOrientation,
      );

  @override
  ThemeExtension<Theming> lerp(covariant ThemeExtension<Theming>? other, double t) =>
      switch (other) {
        Theming _ => other,
        _ => this,
      };

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
  static const bouncyPhysics = AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  static ThemeData generateThemeData(ColorScheme scheme) => ThemeData(
    fontFamily: 'Rubik',
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    disabledColor: scheme.surface,
    unselectedWidgetColor: scheme.surface,
    highlightColor: Colors.transparent,
    cardTheme: const CardThemeData(margin: .all(0)),
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
        iconColor: scheme.onPrimary,
        textStyle: const TextStyle(fontVariations: [FontVariation('wght', 500)]),
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: TextStyle(
        color: scheme.onSecondaryContainer,
        fontVariations: const [FontVariation('wght', 400)],
      ),
    ),
    segmentedButtonTheme: const SegmentedButtonThemeData(
      style: ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    ),
    sliderTheme: const SliderThemeData(
      trackGap: 6,
      trackHeight: 16,
      trackShape: GappedSliderTrackShape(),
      thumbShape: HandleThumbShape(),
      thumbSize: WidgetStatePropertyAll(Size(4, 44)),
    ),
    listTileTheme: const ListTileThemeData(contentPadding: .symmetric(horizontal: offset)),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: fontBig,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      titleMedium: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      titleSmall: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      bodyLarge: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      bodyMedium: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      labelLarge: TextStyle(
        fontSize: fontMedium,
        color: scheme.primary,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      labelMedium: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      labelSmall: TextStyle(
        fontSize: fontSmall,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 350)],
        letterSpacing: 0.5,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionHandleColor: scheme.primary,
      selectionColor: scheme.primary.withAlpha(50),
    ),
    dividerTheme: const DividerThemeData(thickness: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      titleTextStyle: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 500)],
      ),
      contentTextStyle: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
    ),
    tooltipTheme: TooltipThemeData(
      padding: paddingAll,
      textStyle: TextStyle(color: scheme.onSurfaceVariant),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: borderRadiusSmall,
        border: .all(color: scheme.outline),
        boxShadow: [BoxShadow(color: scheme.surface, blurRadius: 10)],
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      interactive: true,
      radius: radiusSmall,
      thickness: .all(5),
      thumbColor: .all(scheme.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      hintStyle: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      border: const OutlineInputBorder(
        borderRadius: borderRadiusSmall,
        borderSide: BorderSide.none,
      ),
    ),
  );
}

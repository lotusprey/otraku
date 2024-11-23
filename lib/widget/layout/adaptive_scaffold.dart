import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold(this.configBuilder);

  final ScaffoldConfigBuilder configBuilder;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < Theming.windowWidthMedium;

    final config = configBuilder(context, compact);

    Color? backgroundColor;
    bool? resizeToAvoidBottomInset;
    if (config.sheetMode) {
      backgroundColor = Colors.transparent;
      resizeToAvoidBottomInset = false;
    }

    var startFabLocation = _StartFloatFabLocation.withoutOffset;
    const endFabLocation = FloatingActionButtonLocation.endFloat;

    var child = config.child;
    var bottomNavigationBar = config.bottomBar;
    if (config.navigationConfig != null) {
      if (compact) {
        bottomNavigationBar = BottomNavigation(
          selected: config.navigationConfig!.selected,
          items: config.navigationConfig!.items,
          onChanged: config.navigationConfig!.onChanged,
          onSame: config.navigationConfig!.onSame,
        );
      } else {
        final sideNavigation = SideNavigation(
          selected: config.navigationConfig!.selected,
          items: config.navigationConfig!.items,
          onChanged: config.navigationConfig!.onChanged,
          onSame: config.navigationConfig!.onSame,
        );

        startFabLocation = _StartFloatFabLocation.withOffset;

        child = Expanded(child: child);
        child = Row(
          children: Directionality.of(context) == TextDirection.ltr
              ? [sideNavigation, child]
              : [child, sideNavigation],
        );
      }
    }

    FloatingActionButtonLocation? floatingActionButtonLocation;

    return Consumer(
      builder: (context, ref, child) {
        final leftHanded = ref.watch(
          persistenceProvider.select((s) => s.options.leftHanded),
        );

        floatingActionButtonLocation =
            leftHanded ? startFabLocation : endFabLocation;

        return SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: backgroundColor,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            appBar: config.topBar,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: config.floatingAction,
            floatingActionButtonLocation: floatingActionButtonLocation,
            body: child,
          ),
        );
      },
      child: child,
    );
  }
}

typedef ScaffoldConfigBuilder = ScaffoldConfig Function(
  BuildContext context,
  bool compact,
);

class ScaffoldConfig {
  const ScaffoldConfig({
    required this.child,
    this.topBar,
    this.floatingAction,
    this.navigationConfig,
    this.bottomBar,
    this.sheetMode = false,
  }) : assert(
          navigationConfig == null || bottomBar == null,
          'Cannot have both a navigation bar and a bottom bar',
        );

  final Widget child;
  final PreferredSizeWidget? topBar;
  final HidingFloatingActionButton? floatingAction;
  final NavigationConfig? navigationConfig;
  final Widget? bottomBar;
  final bool sheetMode;
}

/// A configuration that can be shared
/// between bottom navigation bars and navigation rails.
class NavigationConfig {
  const NavigationConfig({
    required this.selected,
    required this.items,
    required this.onChanged,
    required this.onSame,
  });

  final int selected;
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final void Function(int) onSame;
}

class _StartFloatFabLocation extends StandardFabLocation
    with FabStartOffsetX, FabFloatOffsetY {
  const _StartFloatFabLocation(this.offset);

  static const withOffset = _StartFloatFabLocation(
    Theming.normalTapTarget * 1.5,
  );

  static const withoutOffset = _StartFloatFabLocation(0);

  final double offset;

  @override
  double getOffsetX(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    return switch (scaffoldGeometry.textDirection) {
      TextDirection.rtl =>
        super.getOffsetX(scaffoldGeometry, adjustment + offset),
      TextDirection.ltr =>
        super.getOffsetX(scaffoldGeometry, adjustment - offset),
    };
  }

  @override
  String toString() => 'FloatingActionButtonLocation.startFloatWithOffset';
}

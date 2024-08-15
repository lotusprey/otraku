import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/persistence.dart';
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
        if (config.floatingAction != null) {
          final leftHanded = Persistence().leftHanded;

          floatingActionButtonLocation = leftHanded
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat;
        }

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: config.topBar,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: config.floatingAction,
          floatingActionButtonLocation: floatingActionButtonLocation,
          body: child,
        );
      },
      child: SafeArea(top: false, bottom: false, child: child),
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

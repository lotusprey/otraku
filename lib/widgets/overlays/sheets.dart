import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/overlays/toast.dart';

/// Used to open [DraggableScrollableSheet].
Future<T?> showSheet<T>(BuildContext context, Widget sheet) =>
    showModalBottomSheet<T>(
      context: context,
      builder: (context) => sheet,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.background.withAlpha(100),
    );

/// An implementation of [DraggableScrollableSheet] with opaque background.
class OpaqueSheet extends StatelessWidget {
  OpaqueSheet({required this.builder, this.initialHeight});

  final Widget Function(BuildContext, ScrollController) builder;
  final double? initialHeight;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    double initialSize = initialHeight != null
        ? initialHeight! / MediaQuery.of(context).size.height
        : 0.5;
    if (initialSize > 0.9) initialSize = 0.9;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: initialSize,
        minChildSize: initialSize < 0.25 ? initialSize : 0.25,
        builder: (context, scrollCtrl) {
          if (sheet == null)
            sheet = Center(
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: Consts.LAYOUT_SMALL),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Consts.RADIUS_MAX),
                ),
                child: builder(context, scrollCtrl),
              ),
            );

          return sheet!;
        },
      ),
    );
  }
}

/// A wide implementation of [DraggableScrollableSheet]
/// with a lane of buttons at the bottom.
class OpaqueSheetView extends StatelessWidget {
  OpaqueSheetView({required this.builder, required this.buttons});

  final Widget Function(BuildContext, ScrollController) builder;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        builder: (context, scrollCtrl) {
          if (sheet == null) sheet = _sheetBody(context, scrollCtrl);
          return sheet!;
        },
      ),
    );
  }

  Widget _sheetBody(BuildContext context, ScrollController scrollCtrl) =>
      Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: Consts.LAYOUT_MEDIUM),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Consts.RADIUS_MAX),
          ),
          child: Stack(
            children: [
              builder(context, scrollCtrl),
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: Consts.filter,
                    child: Container(
                      height: MediaQuery.of(context).viewPadding.bottom + 50,
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: MediaQuery.of(context).viewPadding.bottom,
                      ),
                      color: Theme.of(context).cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: Settings().leftHanded
                            ? buttons.reversed.toList()
                            : buttons,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

/// Buttons, typically used in [OpaqueSheetView]
class OpaqueSheetViewButton extends StatelessWidget {
  OpaqueSheetViewButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.warning = false,
  });

  final String text;
  final IconData icon;
  final void Function() onTap;

  // If the icon/text should be in the error colour.
  final bool warning;

  @override
  Widget build(BuildContext context) {
    ButtonStyle style = Theme.of(context).textButtonTheme.style!;
    if (warning)
      style = style.copyWith(
        foregroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.error,
        ),
      );

    return Expanded(
      child: TextButton.icon(
        label: Text(text),
        icon: Icon(icon),
        onPressed: onTap,
        style: style,
      ),
    );
  }
}

/// An implementation of [DraggableScrollableSheet] with
/// gradient background that builds its children cynamically.
class DynamicGradientDragSheet extends StatelessWidget {
  DynamicGradientDragSheet({
    required this.onTap,
    required this.itemBuilder,
    required this.itemCount,
  });

  final void Function(int) onTap;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final requiredHeight = itemCount * Consts.TAP_TARGET_SIZE + 50;
    double height = requiredHeight / MediaQuery.of(context).size.height;
    if (height > 0.9) height = 0.9;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: height,
      minChildSize: height < 0.25 ? height : 0.25,
      builder: (context, scrollCtrl) => Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0, 0.6, 0.9, 1],
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withAlpha(200),
              Theme.of(context).colorScheme.background.withAlpha(150),
              Theme.of(context).colorScheme.background.withAlpha(0),
            ],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.LAYOUT_SMALL),
          child: ListView.builder(
            controller: scrollCtrl,
            padding: const EdgeInsets.only(
              top: 50,
              left: 10,
              right: 10,
            ),
            itemCount: itemCount,
            itemExtent: Consts.TAP_TARGET_SIZE,
            itemBuilder: (context, i) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: itemBuilder(context, i),
              onTap: () {
                onTap(i);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// An implementation of [DraggableScrollableSheet]
/// with gradient background and fixed children.
class FixedGradientDragSheet extends StatelessWidget {
  FixedGradientDragSheet({required this.children});

  // A version with the given buttons, along with copy/open link buttons.
  factory FixedGradientDragSheet.link(
    BuildContext context,
    String link, [
    List<Widget> children = const [],
  ]) =>
      FixedGradientDragSheet(
        children: [
          ...children,
          GradientDragSheetTile(
            text: 'Copy Link',
            icon: Ionicons.clipboard_outline,
            onTap: () => Toast.copy(context, link),
          ),
          GradientDragSheetTile(
            text: 'Open in Browser',
            icon: Ionicons.link_outline,
            onTap: () => Toast.launch(context, link),
          ),
        ],
      );

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final requiredHeight = children.length * Consts.TAP_TARGET_SIZE + 60;
    double height = requiredHeight / MediaQuery.of(context).size.height;
    if (height > 0.9) height = 0.9;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: height,
      minChildSize: height < 0.25 ? height : 0.25,
      builder: (context, scrollCtrl) => Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0, 0.6, 0.9, 1],
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withAlpha(200),
              Theme.of(context).colorScheme.background.withAlpha(150),
              Theme.of(context).colorScheme.background.withAlpha(0),
            ],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.LAYOUT_SMALL),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            itemExtent: Consts.TAP_TARGET_SIZE,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Sometimes used by [FixedGradientDragSheet].
class GradientDragSheetTile extends StatelessWidget {
  GradientDragSheetTile({
    required this.text,
    required this.onTap,
    required this.icon,
  });

  final String text;
  final IconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onBackground),
          const SizedBox(width: 10),
          Text(text, style: Theme.of(context).textTheme.headline1),
        ],
      ),
    );
  }
}

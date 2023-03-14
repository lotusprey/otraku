import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/overlays/toast.dart';

/// Used to open [DraggableScrollableSheet].
Future<T?> showSheet<T>(BuildContext context, Widget sheet) =>
    showModalBottomSheet<T>(
      context: context,
      builder: (context) => sheet,
      isScrollControlled: true,
      barrierColor: Theme.of(context).colorScheme.background.withAlpha(100),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

/// An implementation of [DraggableScrollableSheet] with opaque background.
class OpaqueSheet extends StatelessWidget {
  const OpaqueSheet({required this.builder, this.initialHeight});

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
          sheet ??= Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: Consts.layoutSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius:
                    const BorderRadius.vertical(top: Consts.radiusMax),
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
  const OpaqueSheetView({required this.builder, this.buttons});

  final Widget Function(BuildContext, ScrollController) builder;
  final Widget? buttons;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        builder: (context, scrollCtrl) {
          sheet ??= _sheetBody(context, scrollCtrl);
          return sheet!;
        },
      ),
    );
  }

  Widget _sheetBody(BuildContext context, ScrollController scrollCtrl) =>
      Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: Consts.layoutMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Consts.radiusMax),
          ),
          child: Stack(
            children: [
              builder(context, scrollCtrl),
              if (buttons != null)
                Align(alignment: Alignment.bottomCenter, child: buttons!),
            ],
          ),
        ),
      );
}

/// An implementation of [DraggableScrollableSheet] with
/// gradient background that builds its children dynamically.
class DynamicGradientDragSheet extends StatelessWidget {
  const DynamicGradientDragSheet({required this.children, required this.onTap});

  final List<Widget> children;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final requiredHeight = children.length * Consts.tapTargetSize + 50;
    double height = requiredHeight / MediaQuery.of(context).size.height;
    if (height > 0.6) height = 0.6;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: height,
      minChildSize: height < 0.25 ? height : 0.25,
      maxChildSize: 0.9,
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
          constraints: const BoxConstraints(maxWidth: Consts.layoutSmall),
          child: ListView.builder(
            controller: scrollCtrl,
            padding: const EdgeInsets.only(
              top: 50,
              left: 10,
              right: 10,
            ),
            itemCount: children.length,
            itemExtent: Consts.tapTargetSize,
            itemBuilder: (context, i) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: children[i],
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
  const FixedGradientDragSheet({required this.children});

  // A version with the given buttons, along with copy/open link buttons.
  factory FixedGradientDragSheet.link(
    BuildContext context,
    String link, [
    List<Widget> children = const [],
  ]) =>
      FixedGradientDragSheet(
        children: [
          ...children,
          FixedGradientSheetTile(
            text: 'Copy Link',
            icon: Ionicons.clipboard_outline,
            onTap: () => Toast.copy(context, link),
          ),
          FixedGradientSheetTile(
            text: 'Open in Browser',
            icon: Ionicons.link_outline,
            onTap: () => Toast.launch(context, link),
          ),
        ],
      );

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final requiredHeight = children.length * Consts.tapTargetSize + 60;
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
          constraints: const BoxConstraints(maxWidth: Consts.layoutSmall),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            itemExtent: Consts.tapTargetSize,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Sometimes used by [FixedGradientDragSheet].
class FixedGradientSheetTile extends StatelessWidget {
  const FixedGradientSheetTile({
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
          Text(text, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

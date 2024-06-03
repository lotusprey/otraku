import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/toast.dart';

/// Used to open [DraggableScrollableSheet].
Future<T?> showSheet<T>(BuildContext context, Widget sheet) =>
    showModalBottomSheet<T>(
      context: context,
      builder: (context) => sheet,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

/// An implementation of [DraggableScrollableSheet] with opaque background.
class OpaqueSheet extends StatelessWidget {
  const OpaqueSheet({
    required this.builder,
    this.initialHeight,
  });

  final Widget Function(BuildContext, ScrollController) builder;
  final double? initialHeight;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    double initialSize = initialHeight != null
        ? initialHeight! / MediaQuery.sizeOf(context).height
        : 0.5;
    if (initialSize > 0.9) initialSize = 0.9;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: initialSize,
      minChildSize: initialSize < 0.25 ? initialSize : 0.25,
      builder: (context, scrollCtrl) {
        sheet ??= Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            constraints: const BoxConstraints(maxWidth: Theming.compactWidth),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Theming.radiusBig),
            ),
            child: builder(context, scrollCtrl),
          ),
        );

        return sheet!;
      },
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
      padding: MediaQuery.viewInsetsOf(context),
      child: DraggableScrollableSheet(
        expand: false,
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
          constraints: const BoxConstraints(maxWidth: Theming.compactWidth),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Theming.radiusBig),
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

class GradientSheet extends StatelessWidget {
  const GradientSheet(this.children);

  factory GradientSheet.link(
    BuildContext context,
    String link, [
    List<Widget> children = const [],
  ]) =>
      GradientSheet([
        ...children,
        GradientSheetButton(
          text: 'Copy Link',
          icon: Ionicons.clipboard_outline,
          onTap: () => Toast.copy(context, link),
        ),
        GradientSheetButton(
          text: 'Open in Browser',
          icon: Ionicons.link_outline,
          onTap: () => Toast.launch(context, link),
        ),
      ]);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final requiredHeight = children.length * Theming.tapTargetSize +
        MediaQuery.paddingOf(context).bottom +
        50;

    double height = requiredHeight / MediaQuery.sizeOf(context).height;
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
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withAlpha(200),
              Theme.of(context).colorScheme.surface.withAlpha(150),
              Theme.of(context).colorScheme.surface.withAlpha(0),
            ],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Theming.compactWidth),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.only(
              top: 50,
              left: 10,
              right: 10,
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            itemExtent: Theming.tapTargetSize,
            children: children,
          ),
        ),
      ),
    );
  }
}

class GradientSheetButton extends StatelessWidget {
  const GradientSheetButton({
    required this.text,
    required this.onTap,
    this.selected = false,
    this.icon,
  });

  final String text;
  final IconData? icon;
  final void Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 10),
          ],
          Text(
            text,
            style: selected
                ? theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/toast.dart';

/// Used to open [DraggableScrollableSheet].
Future<T?> showSheet<T>(BuildContext context, Widget sheet) =>
    showModalBottomSheet<T>(
      context: context,
      builder: (context) => sheet,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

/// An implementation of [DraggableScrollableSheet] with opaque background.
class SimpleSheet extends StatelessWidget {
  const SimpleSheet({
    required this.builder,
    this.initialHeight,
  });

  factory SimpleSheet.list(List<Widget> children) => SimpleSheet(
        initialHeight:
            Theming.normalTapTarget * children.length + Theming.offset,
        builder: (context, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.only(top: Theming.offset),
          children: children,
        ),
      );

  factory SimpleSheet.link(
    BuildContext context,
    String link, [
    List<Widget> children = const [],
  ]) =>
      SimpleSheet.list([
        ...children,
        ListTile(
          title: const Text('Copy Link'),
          leading: const Icon(Ionicons.clipboard_outline),
          onTap: () {
            Toast.copy(context, link);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Open in Browser'),
          leading: const Icon(Ionicons.link_outline),
          onTap: () {
            Toast.launch(context, link);
            Navigator.pop(context);
          },
        ),
      ]);

  final Widget Function(BuildContext, ScrollController) builder;
  final double? initialHeight;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final initialFraction = initialHeight != null
        ? (initialHeight! + bottomPadding + Theming.offset)
                .clamp(0, screenHeight) /
            screenHeight
        : 0.5;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialFraction,
      minChildSize: initialFraction < 0.25 ? initialFraction : 0.25,
      builder: (context, scrollCtrl) {
        sheet ??= Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
            constraints: const BoxConstraints(maxWidth: Theming.compactWidth),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Theming.radiusBig),
            ),
            child: Material(
              color: Colors.transparent,
              child: builder(context, scrollCtrl),
            ),
          ),
        );

        return sheet!;
      },
    );
  }
}

/// A wide implementation of [DraggableScrollableSheet]
/// with a lane of buttons at the bottom.
class SheetWithButtonRow extends StatelessWidget {
  const SheetWithButtonRow({required this.builder, this.buttons});

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

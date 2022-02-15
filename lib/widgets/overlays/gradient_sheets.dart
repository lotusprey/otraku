import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Used to open [DraggableScrollableSheet].
Future<T?> showDragSheet<T>(BuildContext context, Widget sheet) =>
    showModalBottomSheet<T>(
      context: context,
      builder: (_) => sheet,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.surface.withAlpha(150),
    );

/// An implementation of [DraggableScrollableSheet] with
/// gradient background that builds its children cynamically.
class DynamicGradientDragSheet extends StatelessWidget {
  DynamicGradientDragSheet({
    required this.onTap,
    required this.itemBuilder,
    required this.itemCount,
    this.itemExtent = Consts.MATERIAL_TAP_TARGET_SIZE,
  });

  final void Function(int) onTap;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final double itemExtent;

  @override
  Widget build(BuildContext context) {
    final requiredHeight = itemCount * itemExtent + 60;
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
            stops: const [0, 0.5, 0.8, 1],
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withAlpha(200),
              Theme.of(context).colorScheme.background.withAlpha(150),
              Theme.of(context).colorScheme.background.withAlpha(0),
            ],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.OVERLAY_TIGHT),
          child: ListView.builder(
            controller: scrollCtrl,
            physics: Consts.PHYSICS,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            itemCount: itemCount,
            itemExtent: itemExtent,
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

  // A default version with commonly used buttons.
  factory FixedGradientDragSheet.link(BuildContext context, String link) =>
      FixedGradientDragSheet(children: linkTiles(context, link));

  // Common buttons for link copying and webpage opening.
  static List<Widget> linkTiles(BuildContext context, String link) => [
        GradientDragSheetTile(
          text: 'Copy Link',
          icon: Ionicons.clipboard_outline,
          onTap: () => Toast.copy(context, link),
        ),
        GradientDragSheetTile(
          text: 'Open in Browser',
          icon: Ionicons.link_outline,
          onTap: () {
            try {
              launch(link);
            } catch (err) {
              Toast.show(context, 'Couldn\'t open link: $err');
            }
          },
        ),
      ];

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final requiredHeight =
        children.length * Consts.MATERIAL_TAP_TARGET_SIZE + 60;
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
            stops: const [0, 0.5, 0.8, 1],
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withAlpha(200),
              Theme.of(context).colorScheme.background.withAlpha(150),
              Theme.of(context).colorScheme.background.withAlpha(0),
            ],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.OVERLAY_TIGHT),
          child: ListView(
            controller: scrollCtrl,
            physics: Consts.PHYSICS,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// An implementation of [DraggableScrollableSheet].
class DragSheet extends StatelessWidget {
  static void show(BuildContext ctx, Widget sheet) => showModalBottomSheet(
        context: ctx,
        builder: (_) => sheet,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Theme.of(ctx).colorScheme.surface.withAlpha(150),
      );

  DragSheet({
    required this.children,
    this.itemExtent = Consts.MATERIAL_TAP_TARGET_SIZE,
  });

  final double itemExtent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final requiredHeight = children.length * itemExtent + 60;
    double height = requiredHeight / MediaQuery.of(context).size.height;
    if (height > 0.9) height = 0.9;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: height,
      minChildSize: height < 0.25 ? height : 0.25,
      builder: (_, sctrollCtrl) => Container(
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
            controller: sctrollCtrl,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            physics: Consts.PHYSICS,
            itemCount: children.length,
            itemExtent: itemExtent,
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ),
    );
  }
}

class OptionDragSheet extends StatelessWidget {
  OptionDragSheet({
    required this.options,
    required this.onTap,
    required this.index,
  });

  final void Function(int) onTap;
  final List<String> options;
  final int index;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < options.length; i++)
      children.add(SizedBox.expand(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(context);
            onTap(i);
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              options[i],
              style: i != index
                  ? Theme.of(context).textTheme.headline1
                  : Theme.of(context).textTheme.headline1?.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
      ));

    return DragSheet(children: children);
  }
}

// Switch between lists in a collection.
class CollectionDragSheet extends StatelessWidget {
  CollectionDragSheet(this.ctx, this.ctrlTag);

  final String ctrlTag;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CollectionController>(tag: ctrlTag);
    final names = ctrl.listNames;
    final counts = ctrl.listCounts;

    final children = <Widget>[];
    for (int i = 0; i < ctrl.listNames.length; i++)
      children.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          ctrl.listIndex = i;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              names[i],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: i != ctrl.listIndex
                  ? Theme.of(context).textTheme.headline1
                  : Theme.of(context).textTheme.headline1?.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 5),
            Text(
              counts[i].toString(),
              style: Theme.of(context).textTheme.headline3,
            ),
          ],
        ),
      ));

    return DragSheet(children: children, itemExtent: 60);
  }
}

// Switch between explore types in the explore tab.
class ExploreDragSheet extends StatelessWidget {
  ExploreDragSheet(this.ctx, this.ctrl);

  final BuildContext ctx;
  final ExploreController ctrl;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < Explorable.values.length; i++)
      children.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          ctrl.type = Explorable.values[i];
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Explorable.values[i].icon,
              color: i != ctrl.type.index
                  ? Theme.of(context).colorScheme.onBackground
                  : Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 5),
            Text(
              Convert.clarifyEnum(Explorable.values[i].name)!,
              style: i != ctrl.type.index
                  ? Theme.of(context).textTheme.headline1
                  : Theme.of(context).textTheme.headline1?.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ));

    return DragSheet(children: children);
  }
}

// Sheet with options to copy or open a link.
class LinkDragSheet extends StatelessWidget {
  const LinkDragSheet(this.link);

  final String link;

  @override
  Widget build(BuildContext context) {
    return DragSheet(
      children: [
        DragSheetListTile(
          text: 'Copy Link',
          icon: Ionicons.clipboard_outline,
          onTap: () => Toast.copy(context, link),
        ),
        DragSheetListTile(
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
      ],
    );
  }
}

/// Used in custom implementations of [DragSheet]
class DragSheetListTile extends StatelessWidget {
  DragSheetListTile({
    required this.text,
    required this.onTap,
    this.selected = false,
    this.icon,
  });

  final String text;
  final IconData? icon;
  final bool selected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: icon == null
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: selected
                    ? Theme.of(context).textTheme.headline1?.copyWith(
                        color: Theme.of(context).colorScheme.secondary)
                    : Theme.of(context).textTheme.headline1,
              ),
            )
          : Row(
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

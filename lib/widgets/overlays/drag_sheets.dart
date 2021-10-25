import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';

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
    required this.ctx,
    this.itemExtent = Config.MATERIAL_TAP_TARGET_SIZE,
  });

  final double itemExtent;
  final List<Widget> children;

  /// A workaround for a bug: [showModalBottomSheet] doesn't respect the top
  /// padding, so [SafeArea] & [MediaQuery.of(context).padding.top] don't work.
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > 420
        ? (MediaQuery.of(context).size.width - 400) / 2
        : 20.0;

    final availableHeight = MediaQuery.of(ctx).size.height;
    final requiredHeight = children.length * itemExtent + 60;

    final size = requiredHeight < availableHeight
        ? requiredHeight / availableHeight
        : 1.0;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: size,
      minChildSize: size < 0.25 ? size : 0.25,
      builder: (_, sctrollCtrl) => Container(
        margin: EdgeInsets.only(top: MediaQuery.of(ctx).viewInsets.top),
        padding:
            EdgeInsets.only(left: sidePadding, right: sidePadding, bottom: 10),
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
        child: ListView.builder(
          controller: sctrollCtrl,
          padding: const EdgeInsets.only(top: 50),
          physics: Config.PHYSICS,
          itemCount: children.length,
          itemExtent: itemExtent,
          itemBuilder: (_, i) => children[i],
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
                  ? Theme.of(context).textTheme.headline2
                  : Theme.of(context).textTheme.headline1,
            ),
          ),
        ),
      ));

    return DragSheet(ctx: context, children: children);
  }
}

// Switch between lists in a collection.
class CollectionDragSheet extends StatelessWidget {
  CollectionDragSheet(this.ctx, this.collectionTag);
  final String collectionTag;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CollectionController>(tag: collectionTag);
    final names = ctrl.names;
    final counts = ctrl.allEntryCounts;

    final children = <Widget>[];
    for (int i = 0; i < ctrl.names.length; i++)
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
                  ? Theme.of(context).textTheme.headline2
                  : Theme.of(context).textTheme.headline1,
            ),
            const SizedBox(height: 5),
            Text(
              counts[i].toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ));

    return DragSheet(ctx: ctx, itemExtent: 60, children: children);
  }
}

// Switch between explore types in the explore tab.
class ExploreDragSheet extends StatelessWidget {
  ExploreDragSheet(this.ctx);
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExploreController>();

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
              Convert.clarifyEnum(describeEnum(Explorable.values[i]))!,
              style: i != ctrl.type.index
                  ? Theme.of(context).textTheme.headline2
                  : Theme.of(context).textTheme.headline1,
            ),
          ],
        ),
      ));

    return DragSheet(ctx: ctx, children: children);
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
                    ? Theme.of(context).textTheme.headline1
                    : Theme.of(context).textTheme.headline2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon),
                const SizedBox(width: 5),
                Text(text, style: Theme.of(context).textTheme.headline2),
              ],
            ),
    );
  }
}

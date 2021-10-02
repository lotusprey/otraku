import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class BottomDrawer extends StatelessWidget {
  static void show(BuildContext ctx, Widget drawer) => Sheet.show(
        ctx: ctx,
        sheet: drawer,
        isScrollControlled: true,
        barrierColour: Theme.of(ctx).colorScheme.surface.withAlpha(150),
      );

  final double itemExtent;
  final List<Widget> children;
  // A workaround for a bug: showModalBottomSheet doesn't respect the top
  // padding, so SafeArea() and MediaQuery.of(context).padding.top don't work.
  final BuildContext ctx;

  BottomDrawer({
    required this.children,
    required this.ctx,
    this.itemExtent = 50,
  });

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

class CollectionBottomDrawer extends StatelessWidget {
  final String collectionTag;
  final BuildContext ctx;
  CollectionBottomDrawer(this.ctx, this.collectionTag);

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

    return BottomDrawer(ctx: ctx, itemExtent: 60, children: children);
  }
}

class ExploreBottomDrawer extends StatelessWidget {
  final BuildContext ctx;
  ExploreBottomDrawer(this.ctx);

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

    return BottomDrawer(ctx: ctx, children: children);
  }
}

// Used in custom implementations of BottomDrawer
class BottomDrawerListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function() onTap;

  BottomDrawerListTile({
    required this.text,
    required this.icon,
    required this.onTap,
  });

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
          Icon(icon),
          const SizedBox(width: 5),
          Text(text, style: Theme.of(context).textTheme.headline2),
        ],
      ),
    );
  }
}

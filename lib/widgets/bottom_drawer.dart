import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';

class _BottomDrawer extends StatelessWidget {
  final int itemCount;
  final double itemExtent;
  final Widget Function(int) itemBuilder;
  final void Function(int) onChanged;
  // A workaround for a bug: showModalBottomSheet doesn't respect the top
  // padding, so SafeArea() and MediaQuery.of(context).padding.top don't work.
  final BuildContext ctx;

  _BottomDrawer({
    required this.itemCount,
    required this.itemExtent,
    required this.itemBuilder,
    required this.onChanged,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > 420
        ? (MediaQuery.of(context).size.width - 400) / 2
        : 20.0;

    final availableHeight = MediaQuery.of(ctx).size.height;
    final requiredHeight = itemCount * itemExtent + 60;

    final size = requiredHeight < availableHeight
        ? requiredHeight / availableHeight
        : 1.0;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: size,
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
              Theme.of(context).backgroundColor,
              Theme.of(context).backgroundColor.withAlpha(200),
              Theme.of(context).backgroundColor.withAlpha(150),
              Theme.of(context).backgroundColor.withAlpha(0),
            ],
          ),
        ),
        child: ListView.builder(
          controller: sctrollCtrl,
          padding: const EdgeInsets.only(top: 50),
          physics: Config.PHYSICS,
          itemCount: itemCount,
          itemExtent: itemExtent,
          itemBuilder: (_, i) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
              onChanged(i);
            },
            child: itemBuilder(i),
          ),
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

    return _BottomDrawer(
      ctx: ctx,
      itemExtent: 60,
      itemCount: names.length,
      itemBuilder: (i) => Column(
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
      onChanged: (i) => ctrl.listIndex = i,
    );
  }
}

class ExploreBottomDrawer extends StatelessWidget {
  final BuildContext ctx;
  ExploreBottomDrawer(this.ctx);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExploreController>();

    return _BottomDrawer(
      ctx: ctx,
      itemExtent: 50,
      itemCount: Explorable.values.length,
      itemBuilder: (i) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Explorable.values[i].icon,
            color: i != ctrl.type.index
                ? Theme.of(context).dividerColor
                : Theme.of(context).accentColor,
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
      onChanged: (i) => ctrl.type = Explorable.values[i],
    );
  }
}

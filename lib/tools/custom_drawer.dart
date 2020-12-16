import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';

class CustomDrawer extends StatelessWidget {
  final String heading;
  final int index;
  final int length;
  final Function(int) onChanged;
  final Widget Function(int) titleBuilder;
  final Widget Function(int) subtitleBuilder;

  CustomDrawer({
    @required this.index,
    @required this.length,
    @required this.onChanged,
    @required this.titleBuilder,
    @required this.subtitleBuilder,
    this.heading = '',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).backgroundColor,
              Theme.of(context).backgroundColor.withAlpha(0),
            ],
          ),
        ),
        child: ListView(
          physics: Config.PHYSICS,
          padding: const EdgeInsets.symmetric(vertical: 52),
          children: [
            Text(heading, style: Theme.of(context).textTheme.headline4),
            const SizedBox(height: 20),
            for (int i = 0; i < length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(context);
                    if (i != index) onChanged(i);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [titleBuilder(i), subtitleBuilder(i)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CollectionDrawer extends StatelessWidget {
  const CollectionDrawer();

  @override
  Widget build(BuildContext context) {
    final collection = Get.find<Collections>().collection;
    final selected = collection.listIndex;
    final names = collection.listNames;
    final counts = collection.listEntryCounts;

    return CustomDrawer(
      heading: '${collection.totalEntryCount} Total',
      index: collection.listIndex,
      length: names.length,
      onChanged: (int index) => collection.listIndex = index,
      titleBuilder: (int i) => Text(
        names[i],
        style: i != selected
            ? Theme.of(context).textTheme.headline3
            : Theme.of(context).textTheme.headline2,
      ),
      subtitleBuilder: (int i) => Text(
        counts[i].toString(),
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}

class ExploreDrawer extends StatelessWidget {
  final _space = const SizedBox(width: 10);

  const ExploreDrawer();

  @override
  Widget build(BuildContext context) {
    final explorable = Get.find<Explorable>();
    final selected = explorable.type.index;

    return CustomDrawer(
      heading: 'Looking for:',
      index: selected,
      length: Browsable.values.length,
      titleBuilder: (int i) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Browsable.values[i].icon,
            color: i != selected
                ? Theme.of(context).dividerColor
                : Theme.of(context).accentColor,
          ),
          _space,
          Text(
            clarifyEnum(describeEnum(Browsable.values[i])),
            style: i != selected
                ? Theme.of(context).textTheme.headline3
                : Theme.of(context).textTheme.headline2,
          ),
        ],
      ),
      subtitleBuilder: (_) => const SizedBox(),
      onChanged: (int index) => explorable.type = Browsable.values[index],
    );
  }
}

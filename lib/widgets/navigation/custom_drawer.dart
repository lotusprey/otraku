import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/convert.dart';

class CustomDrawer extends StatelessWidget {
  final String heading;
  final int index;
  final int length;
  final Function(int) onChanged;
  final Widget Function(int) titleBuilder;
  final Widget Function(int) subtitleBuilder;

  CustomDrawer({
    required this.index,
    required this.length,
    required this.onChanged,
    required this.titleBuilder,
    required this.subtitleBuilder,
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
            Text(
              heading,
              style: Theme.of(context).textTheme.headline3,
            ),
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
  final String? collectionTag;

  const CollectionDrawer(this.collectionTag);

  @override
  Widget build(BuildContext context) {
    final collection = Get.find<Collection>(tag: collectionTag);
    final selected = collection.listIndex;
    final names = collection.names;
    final counts = collection.allEntryCounts;

    return CustomDrawer(
      heading: '${collection.totalEntryCount} Total',
      index: collection.listIndex,
      length: names.length,
      onChanged: (int index) => collection.listIndex = index,
      titleBuilder: (int i) => Text(
        names[i],
        style: i != selected
            ? Theme.of(context).textTheme.headline2
            : Theme.of(context).textTheme.headline1,
      ),
      subtitleBuilder: (int i) => Text(
        counts[i].toString(),
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }
}

class ExploreDrawer extends StatelessWidget {
  final _space = const SizedBox(width: 10);

  const ExploreDrawer();

  @override
  Widget build(BuildContext context) {
    final explorable = Get.find<Explorer>();
    final selected = explorable.type.index;

    return CustomDrawer(
      heading: 'Looking for:',
      index: selected,
      length: Explorable.values.length,
      titleBuilder: (int i) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Explorable.values[i].icon,
            color: i != selected
                ? Theme.of(context).dividerColor
                : Theme.of(context).accentColor,
          ),
          _space,
          Text(
            Convert.clarifyEnum(describeEnum(Explorable.values[i]))!,
            style: i != selected
                ? Theme.of(context).textTheme.headline2
                : Theme.of(context).textTheme.headline1,
          ),
        ],
      ),
      subtitleBuilder: (_) => const SizedBox(),
      onChanged: (int index) => explorable.type = Explorable.values[index],
    );
  }
}

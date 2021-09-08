import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/viewer_controller.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/widgets/fields/three_state_field.dart';
import 'package:otraku/widgets/fields/two_state_field.dart';

class Sheet extends StatelessWidget {
  static void show({
    required BuildContext ctx,
    required Widget sheet,
    bool isScrollControlled = false,
    Color? barrierColour,
  }) =>
      showModalBottomSheet(
        context: ctx,
        builder: (_) => sheet,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        barrierColor: barrierColour ??
            Theme.of(ctx).colorScheme.background.withAlpha(200),
      );

  final Widget child;
  final double? height;
  final void Function()? onDone;

  Sheet({
    required this.child,
    this.height,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final sideMargin = MediaQuery.of(context).size.width > 420
        ? (MediaQuery.of(context).size.width - 400) / 2
        : 20.0;

    return Container(
      height: height,
      margin: EdgeInsets.only(
        left: sideMargin,
        right: sideMargin,
        bottom: MediaQuery.of(context).viewPadding.bottom + 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: Config.BORDER_RADIUS,
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            offset: Offset(5, 5),
            color: Colors.black45,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(child: child),
          if (onDone != null)
            TextButton.icon(
              onPressed: () {
                onDone!();
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.done_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: Theming.ICON_SMALL,
              ),
              label: Text('Done', style: Theme.of(context).textTheme.bodyText1),
            ),
        ],
      ),
    );
  }
}

class OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final int index;
  final Function(int) onTap;

  OptionSheet({
    required this.title,
    required this.options,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Sheet(
        height: options.length * Config.MATERIAL_TAP_TARGET_SIZE + 50.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: Config.PADDING,
              child: Text(title, style: Theme.of(context).textTheme.subtitle1),
            ),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(
                    options[i],
                    style: i != index
                        ? Theme.of(context).textTheme.bodyText2
                        : Theme.of(context).textTheme.bodyText1,
                  ),
                  trailing: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i != index
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onTap: () {
                    onTap(i);
                    Navigator.pop(context);
                  },
                ),
                itemCount: options.length,
                itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
              ),
            ),
          ],
        ),
      );
}

class SelectionSheet<T> extends StatelessWidget {
  final List<String> options;
  final List<T> values;
  final List<T> inclusive;
  final List<T>? exclusive;
  final Function(List<T>, List<T>?) onDone;
  final bool fixHeight;

  SelectionSheet({
    required this.onDone,
    required this.options,
    required this.values,
    required this.inclusive,
    this.exclusive,
    this.fixHeight = false,
  });

  @override
  Widget build(BuildContext context) => Sheet(
        height: fixHeight
            ? options.length * Config.MATERIAL_TAP_TARGET_SIZE + 50
            : null,
        child: ListView.builder(
          physics:
              fixHeight ? const NeverScrollableScrollPhysics() : Config.PHYSICS,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (_, index) => exclusive == null
              ? TwoStateField(
                  title: options[index],
                  initial: inclusive.contains(values[index]),
                  onChanged: (val) => val
                      ? inclusive.add(values[index])
                      : inclusive.remove(values[index]),
                )
              : ThreeStateField(
                  title: options[index],
                  initialState: inclusive.contains(values[index])
                      ? 1
                      : exclusive!.contains(values[index])
                          ? 2
                          : 0,
                  onChanged: (state) {
                    if (state == 0)
                      exclusive!.remove(values[index]);
                    else if (state == 1)
                      inclusive.add(values[index]);
                    else {
                      inclusive.remove(values[index]);
                      exclusive!.add(values[index]);
                    }
                  },
                ),
          itemCount: options.length,
          itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
        ),
        onDone: () => onDone(inclusive, exclusive),
      );
}

class TagSelectionSheet extends StatelessWidget {
  final Map<String, List<TagModel>> tags;
  final List<String> inclusive;
  final List<String> exclusive;
  final Function(List<String>, List<String>) onDone;

  TagSelectionSheet({
    required this.tags,
    required this.inclusive,
    required this.exclusive,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    int count = 0;
    final slivers = <Widget>[];
    for (int i = 0; i < tags.length; i++) {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: Config.PADDING,
          child: Text(
            tags.entries.elementAt(i).key,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ));

      slivers.add(SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final val = tags.entries.elementAt(i).value[index].name;
            return ThreeStateField(
              title: val,
              initialState: inclusive.contains(val)
                  ? 1
                  : exclusive.contains(val)
                      ? 2
                      : 0,
              onChanged: (state) {
                if (state == 0)
                  exclusive.remove(val);
                else if (state == 1)
                  inclusive.add(val);
                else {
                  inclusive.remove(val);
                  exclusive.add(val);
                }
              },
            );
          },
          childCount: tags.entries.elementAt(i).value.length,
          semanticIndexOffset: count,
        ),
        itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
      ));

      count += tags.entries.elementAt(i).value.length;
    }

    return Sheet(
      height: null,
      child: CustomScrollView(
        physics: Config.PHYSICS,
        semanticChildCount: count,
        slivers: slivers,
      ),
      onDone: () => onDone(inclusive, exclusive),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final List<String> options;
  final int index;
  final bool desc;
  final Function(int, bool) onTap;

  _SortSheet({
    required this.options,
    required this.index,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Sheet(
        height: options.length * Config.MATERIAL_TAP_TARGET_SIZE + 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 15,
                right: 45,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort', style: Theme.of(context).textTheme.subtitle1),
                  Text('Order', style: Theme.of(context).textTheme.subtitle1),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(
                    options[i],
                    style: i != index
                        ? Theme.of(context).textTheme.bodyText2
                        : Theme.of(context).textTheme.bodyText1,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i != index || !desc
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                            size: Theming.ICON_SMALL,
                          ),
                          color: Theme.of(context).colorScheme.background,
                          onPressed: () {
                            onTap(i, true);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i != index || desc
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                            size: Theming.ICON_SMALL,
                          ),
                          color: Theme.of(context).colorScheme.background,
                          onPressed: () {
                            onTap(i, false);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                itemCount: options.length,
                itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
              ),
            ),
          ],
        ),
      );
}

class CollectionSortSheet extends StatelessWidget {
  final String collectionTag;
  CollectionSortSheet(this.collectionTag);

  @override
  Widget build(BuildContext context) {
    final collection = Get.find<CollectionController>(tag: collectionTag);

    final EntrySort entrySort = collection.getFilterWithKey(Filterable.SORT);
    final currentIndex = entrySort.index ~/ 2;
    final currentlyDesc = entrySort.index % 2 == 0 ? false : true;

    final options = <String>[];
    for (int i = 0; i < EntrySort.values.length; i += 2)
      options.add(Convert.clarifyEnum(describeEnum(EntrySort.values[i]))!);

    return _SortSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index, bool desc) {
        collection.setFilterWithKey(
          Filterable.SORT,
          value: desc
              ? EntrySort.values[index * 2 + 1]
              : EntrySort.values[index * 2],
        );
        collection.sort();
      },
    );
  }
}

class MediaSortSheet extends StatelessWidget {
  final MediaSort initial;
  final void Function(MediaSort) onTap;
  MediaSortSheet(this.initial, this.onTap);

  @override
  Widget build(BuildContext context) {
    final length = MediaSort.values.length;
    final prefTitle = Get.find<ViewerController>().settings!.titleLanguage;
    late MediaSort titleAsc;
    late MediaSort titleDesc;

    // Check which title is the preferred one.
    for (int i = 0; i < length; i += 2)
      if (describeEnum(MediaSort.values[i]).contains(prefTitle)) {
        titleAsc = MediaSort.values[i];
        titleDesc = MediaSort.values[i + 1];
      }

    int currentIndex = initial.index ~/ 2;
    bool currentlyDesc = initial.index % 2 == 0 ? false : true;

    if (currentIndex > (length - 5) ~/ 2) currentIndex = (length - 6) ~/ 2;

    // Gather the sort options as user-readable strings.
    final options = ['Date Added'];
    for (int i = 2; i < length - 6; i += 2)
      options.add(Convert.clarifyEnum(describeEnum(MediaSort.values[i]))!);
    options.add('Title');

    return _SortSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (index, desc) {
        if (index != options.length - 1)
          desc
              ? onTap(MediaSort.values[index * 2 + 1])
              : onTap(MediaSort.values[index * 2]);
        else
          desc ? onTap(titleDesc) : onTap(titleAsc);
      },
    );
  }
}

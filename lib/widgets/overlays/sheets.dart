import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/three_state_field.dart';
import 'package:otraku/widgets/fields/two_state_field.dart';

class Sheet extends StatelessWidget {
  static void show({
    @required BuildContext ctx,
    @required Widget sheet,
    bool isScrollControlled = false,
  }) =>
      showModalBottomSheet(
        context: ctx,
        builder: (_) => sheet,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
      );

  final Widget child;
  final double height;
  final Function onDone;

  Sheet({
    @required this.child,
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
        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        children: [
          Expanded(child: child),
          if (onDone != null)
            TextButton.icon(
              onPressed: () {
                onDone();
                Navigator.pop(context);
              },
              icon: Icon(
                FluentIcons.checkmark_20_filled,
                color: Theme.of(context).accentColor,
                size: Style.ICON_SMALL,
              ),
              label: Text('Done', style: Theme.of(context).textTheme.bodyText2),
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
    @required this.title,
    @required this.options,
    @required this.index,
    @required this.onTap,
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
                        ? Theme.of(context).textTheme.bodyText1
                        : Theme.of(context).textTheme.bodyText2,
                  ),
                  trailing: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i != index
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).accentColor,
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
  final List<T> exclusive;
  final Function(List<T>, List<T>) onDone;
  final bool fixHeight;

  SelectionSheet({
    @required this.onDone,
    @required this.options,
    @required this.values,
    @required this.inclusive,
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
                  onChanged: (val) {
                    if (val)
                      inclusive.add(values[index]);
                    else
                      inclusive.remove(values[index]);
                  },
                )
              : ThreeStateField(
                  title: options[index],
                  initialState: inclusive.contains(values[index])
                      ? 1
                      : exclusive.contains(values[index])
                          ? 2
                          : 0,
                  onChanged: (state) {
                    if (state == 0) {
                      exclusive.remove(values[index]);
                    } else if (state == 1) {
                      inclusive.add(values[index]);
                    } else {
                      inclusive.remove(values[index]);
                      exclusive.add(values[index]);
                    }
                  },
                ),
          itemCount: options.length,
          itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
        ),
        onDone: () => onDone(inclusive, exclusive),
      );
}

class _SortSheet extends StatelessWidget {
  final List<String> options;
  final int index;
  final bool desc;
  final Function(int, bool) onTap;

  _SortSheet({
    @required this.options,
    @required this.index,
    @required this.desc,
    @required this.onTap,
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
                        ? Theme.of(context).textTheme.bodyText1
                        : Theme.of(context).textTheme.bodyText2,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i != index || !desc
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).accentColor,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(
                            FluentIcons.arrow_down_20_filled,
                            size: Style.ICON_SMALL,
                          ),
                          color: Theme.of(context).backgroundColor,
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
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).accentColor,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(
                            FluentIcons.arrow_up_20_filled,
                            size: Style.ICON_SMALL,
                          ),
                          color: Theme.of(context).backgroundColor,
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
    final collection = Get.find<Collection>(tag: collectionTag);

    final mediaSort = collection.getFilterWithKey(Filterable.SORT);
    final currentIndex = mediaSort.index ~/ 2;
    final currentlyDesc = mediaSort.index % 2 == 0 ? false : true;

    List<String> options = [];
    for (int i = 0; i < ListSort.values.length; i += 2) {
      options.add(Convert.clarifyEnum(describeEnum(ListSort.values[i])));
    }

    return _SortSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index, bool desc) {
        collection.setFilterWithKey(
          Filterable.SORT,
          value: desc
              ? ListSort.values[index * 2 + 1]
              : ListSort.values[index * 2],
        );
        collection.sort();
      },
    );
  }
}

class MediaSortSheet extends StatelessWidget {
  final MediaSort initial;
  final Function(MediaSort) onTap;

  MediaSortSheet(this.initial, this.onTap);

  @override
  Widget build(BuildContext context) {
    final length = MediaSort.values.length;
    final prefTitle = Get.find<Viewer>().settings.titleLanguage;
    MediaSort titleAsc;
    MediaSort titleDesc;

    if (describeEnum(MediaSort.values[length - 2]).contains(prefTitle)) {
      titleAsc = MediaSort.values[length - 2];
      titleDesc = MediaSort.values[length - 1];
    } else if (describeEnum(MediaSort.values[length - 4]).contains(prefTitle)) {
      titleAsc = MediaSort.values[length - 4];
      titleDesc = MediaSort.values[length - 3];
    } else {
      titleAsc = MediaSort.values[length - 6];
      titleDesc = MediaSort.values[length - 5];
    }

    int currentIndex = initial.index ~/ 2;
    bool currentlyDesc = initial.index % 2 == 0 ? false : true;

    if (currentIndex > (length - 5) ~/ 2) {
      currentIndex = (length - 6) ~/ 2;
    }

    List<String> options = [];
    for (int i = 0; i < length - 6; i += 2) {
      options.add(Convert.clarifyEnum(describeEnum(MediaSort.values[i])));
    }
    options.add('Title');

    return _SortSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (index, desc) {
        if (index != options.length - 1) {
          if (desc) {
            onTap(MediaSort.values[index * 2 + 1]);
          } else {
            onTap(MediaSort.values[index * 2]);
          }
        } else {
          if (desc) {
            onTap(titleDesc);
          } else {
            onTap(titleAsc);
          }
        }
      },
    );
  }
}

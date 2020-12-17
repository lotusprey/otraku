import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/users.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/controllers/filterable.dart';

class SortSheet extends StatelessWidget {
  final List<String> options;
  final int index;
  final bool desc;
  final Function(int, bool) onTap;

  SortSheet({
    @required this.options,
    @required this.index,
    @required this.desc,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: options.length * Config.MATERIAL_TAP_TARGET_SIZE + 50.0,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 46, bottom: 10),
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
              physics: Config.PHYSICS,
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
                          FluentSystemIcons.ic_fluent_arrow_down_filled,
                          size: Styles.ICON_SMALLER,
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
                          FluentSystemIcons.ic_fluent_arrow_up_filled,
                          size: Styles.ICON_SMALLER,
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
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionSortSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collection = Get.find<Collections>().collection;

    final mediaSort = collection.getFilterWithKey(Filterable.SORT);
    final currentIndex = mediaSort.index ~/ 2;
    final currentlyDesc = mediaSort.index % 2 == 0 ? false : true;

    List<String> options = [];
    for (int i = 0; i < ListSort.values.length; i += 2) {
      options.add(clarifyEnum(describeEnum(ListSort.values[i])));
    }

    return SortSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index, bool desc) {
        collection.setFilterWithKey(
          Filterable.SORT,
          value: desc
              ? ListSort.values[index * 2 + 1]
              : ListSort.values[index * 2],
          update: true,
        );
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
    final prefTitle = Get.find<Users>().settings.titleLanguage;
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
      options.add(clarifyEnum(describeEnum(MediaSort.values[i])));
    }
    options.add('Title');

    return SortSheet(
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

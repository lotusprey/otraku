import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/tools/overlays/modal_sheet.dart';

class CollectionSortModalSheet extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Function load;

  CollectionSortModalSheet(this.filters, this.load);

  @override
  Widget build(BuildContext context) {
    MediaListSort mediaSort = stringToEnum(
      filters['sort'],
      Map.fromIterable(
        MediaListSort.values,
        key: (element) => describeEnum(element),
        value: (element) => element,
      ),
    );

    int currentIndex;
    bool currentlyDesc;

    for (int i = 0; i < MediaListSort.values.length; i++) {
      if (mediaSort == MediaListSort.values[i]) {
        currentIndex = i ~/ 2;
        currentlyDesc = i % 2 == 0 ? false : true;
        break;
      }
    }

    List<String> options = [];
    for (int i = 0; i < MediaListSort.values.length; i += 2) {
      options.add(clarifyEnum(describeEnum(MediaListSort.values[i])));
    }

    return ModalSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index) {
        if (index != currentIndex) {
          filters['sort'] = describeEnum(MediaListSort.values[index * 2 + 1]);
        } else {
          if (currentlyDesc) {
            filters['sort'] = describeEnum(MediaListSort.values[index * 2]);
          } else {
            filters['sort'] = describeEnum(MediaListSort.values[index * 2 + 1]);
          }
        }
        load(forceLoad: true);
      },
    );
  }
}

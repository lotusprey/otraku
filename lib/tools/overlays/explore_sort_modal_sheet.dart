import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/tools/overlays/modal_sheet.dart';

class ExploreSortModalSheet extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Function load;

  ExploreSortModalSheet(this.filters, this.load);

  @override
  Widget build(BuildContext context) {
    MediaSort mediaSort = stringToEnum(
      filters['sort'],
      Map.fromIterable(
        MediaSort.values,
        key: (element) => describeEnum(element),
        value: (element) => element,
      ),
    );

    int currentIndex;
    bool currentlyDesc;

    for (int i = 0; i < MediaSort.values.length; i++) {
      if (mediaSort == MediaSort.values[i]) {
        currentIndex = i ~/ 2;
        currentlyDesc = i % 2 == 0 ? false : true;
        break;
      }
    }

    List<String> options = [];
    for (int i = 0; i < MediaSort.values.length; i += 2) {
      options.add(clarifyEnum(describeEnum(MediaSort.values[i])));
    }

    return ModalSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index) {
        if (index != currentIndex) {
          filters['sort'] = describeEnum(MediaSort.values[index * 2 + 1]);
        } else {
          if (currentlyDesc) {
            filters['sort'] = describeEnum(MediaSort.values[index * 2]);
          } else {
            filters['sort'] = describeEnum(MediaSort.values[index * 2 + 1]);
          }
        }
        load();
      },
    );
  }
}

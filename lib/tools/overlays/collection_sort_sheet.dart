import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/tools/overlays/modal_sort_sheet.dart';

class CollectionSortSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collection = Get.find<Collections>().collection;

    final mediaSort = collection.sort;
    final currentIndex = mediaSort.index ~/ 2;
    final currentlyDesc = mediaSort.index % 2 == 0 ? false : true;

    List<String> options = [];
    for (int i = 0; i < ListSort.values.length; i += 2) {
      options.add(clarifyEnum(describeEnum(ListSort.values[i])));
    }

    return ModalSortSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index) {
        if (index == currentIndex) {
          if (currentlyDesc) {
            collection.sort = ListSort.values[index * 2];
          } else {
            collection.sort = ListSort.values[index * 2 + 1];
          }
        } else {
          collection.sort = ListSort.values[index * 2];
        }
      },
    );
  }
}

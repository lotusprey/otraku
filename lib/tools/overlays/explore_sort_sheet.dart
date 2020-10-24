import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/users.dart';
import 'package:otraku/tools/overlays/modal_sort_sheet.dart';
import 'package:provider/provider.dart';

class ExploreSortSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Explorable>(context, listen: false);

    final length = MediaSort.values.length;
    final prefTitle =
        Provider.of<Users>(context, listen: false).settings.titleFormat;
    String titleAsc;
    String titleDesc;

    if (describeEnum(MediaSort.values[length - 2]).contains(prefTitle)) {
      titleAsc = describeEnum(MediaSort.values[length - 2]);
      titleDesc = describeEnum(MediaSort.values[length - 1]);
    } else if (describeEnum(MediaSort.values[length - 4]).contains(prefTitle)) {
      titleAsc = describeEnum(MediaSort.values[length - 4]);
      titleDesc = describeEnum(MediaSort.values[length - 3]);
    } else {
      titleAsc = describeEnum(MediaSort.values[length - 6]);
      titleDesc = describeEnum(MediaSort.values[length - 5]);
    }

    MediaSort mediaSort = stringToEnum(provider.sort, MediaSort.values);

    int currentIndex = mediaSort.index ~/ 2;
    bool currentlyDesc = mediaSort.index % 2 == 0 ? false : true;

    if (currentIndex > (length - 5) ~/ 2) {
      currentIndex = (length - 6) ~/ 2;
    }

    List<String> options = [];
    for (int i = 0; i < length - 6; i += 2) {
      options.add(clarifyEnum(describeEnum(MediaSort.values[i])));
    }
    options.add('Title');

    return ModalSortSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index) {
        if (index != options.length - 1) {
          if (index != currentIndex || !currentlyDesc) {
            provider.sort = describeEnum(MediaSort.values[index * 2 + 1]);
          } else {
            provider.sort = describeEnum(MediaSort.values[index * 2]);
          }
        } else {
          if (index != currentIndex || !currentlyDesc) {
            provider.sort = titleDesc;
          } else {
            provider.sort = titleAsc;
          }
        }
      },
    );
  }
}

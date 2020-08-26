import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/tools/overlays/modal_sheet.dart';
import 'package:provider/provider.dart';

class CollectionSortSheet extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Function load;

  CollectionSortSheet(this.filters, this.load);

  @override
  Widget build(BuildContext context) {
    final length = MediaListSort.values.length;
    final prefTitle = Provider.of<Auth>(context, listen: false).titleFormat;
    String titleAsc;
    String titleDesc;

    if (describeEnum(MediaListSort.values[length - 2]).contains(prefTitle)) {
      titleAsc = describeEnum(MediaListSort.values[length - 2]);
      titleDesc = describeEnum(MediaListSort.values[length - 1]);
    } else if (describeEnum(MediaListSort.values[length - 4])
        .contains(prefTitle)) {
      titleAsc = describeEnum(MediaListSort.values[length - 4]);
      titleDesc = describeEnum(MediaListSort.values[length - 3]);
    } else {
      titleAsc = describeEnum(MediaListSort.values[length - 6]);
      titleDesc = describeEnum(MediaListSort.values[length - 5]);
    }

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

    for (int i = 0; i < length; i++) {
      if (mediaSort == MediaListSort.values[i]) {
        currentIndex = i ~/ 2;
        currentlyDesc = i % 2 == 0 ? false : true;
        break;
      }
    }

    if (currentIndex > (length - 5) ~/ 2) {
      currentIndex = (length - 6) ~/ 2;
    }

    List<String> options = [];
    for (int i = 0; i < length - 6; i += 2) {
      options.add(
        _removeMediaKeyword(clarifyEnum(describeEnum(MediaListSort.values[i]))),
      );
    }
    options.add('Title');

    return ModalSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index) {
        if (index != options.length - 1) {
          if (index != currentIndex) {
            filters['sort'] = describeEnum(MediaListSort.values[index * 2 + 1]);
          } else {
            if (currentlyDesc) {
              filters['sort'] = describeEnum(MediaListSort.values[index * 2]);
            } else {
              filters['sort'] =
                  describeEnum(MediaListSort.values[index * 2 + 1]);
            }
          }
        } else {
          if (index != currentIndex) {
            filters['sort'] = titleDesc;
          } else if (currentlyDesc) {
            filters['sort'] = titleAsc;
          } else {
            filters['sort'] = titleDesc;
          }
        }

        load(forceLoad: true);
      },
    );
  }

  String _removeMediaKeyword(String str) {
    if (str[0] == 'M') {
      return str.substring(6);
    }

    return str;
  }
}

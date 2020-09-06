import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/tools/overlays/modal_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionSortSheet extends StatelessWidget {
  final bool isAnimeCollection;

  CollectionSortSheet(this.isAnimeCollection);

  @override
  Widget build(BuildContext context) {
    Collection collection;
    if (isAnimeCollection) {
      collection = Provider.of<AnimeCollection>(context, listen: false);
    } else {
      collection = Provider.of<MangaCollection>(context, listen: false);
    }

    final length = MediaListSort.values.length;
    final prefTitle = Provider.of<Auth>(context, listen: false).titleFormat;
    MediaListSort titleAsc;
    MediaListSort titleDesc;

    if (describeEnum(MediaListSort.values[length - 2]).contains(prefTitle)) {
      titleAsc = MediaListSort.values[length - 2];
      titleDesc = MediaListSort.values[length - 1];
    } else if (describeEnum(MediaListSort.values[length - 4])
        .contains(prefTitle)) {
      titleAsc = MediaListSort.values[length - 4];
      titleDesc = MediaListSort.values[length - 3];
    } else {
      titleAsc = MediaListSort.values[length - 6];
      titleDesc = MediaListSort.values[length - 5];
    }

    MediaListSort mediaSort = stringToEnum(
      describeEnum(collection.sort),
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
            collection.sort = MediaListSort.values[index * 2 + 1];
            SharedPreferences.getInstance()
                .then((prefs) => prefs.setInt('sort', index * 2 + 1));
          } else {
            if (currentlyDesc) {
              collection.sort = MediaListSort.values[index * 2];
              SharedPreferences.getInstance()
                  .then((prefs) => prefs.setInt('sort', index * 2));
            } else {
              collection.sort = MediaListSort.values[index * 2 + 1];
              SharedPreferences.getInstance()
                  .then((prefs) => prefs.setInt('sort', index * 2 + 1));
            }
          }
        } else {
          if (index != currentIndex) {
            collection.sort = titleDesc;
          } else if (currentlyDesc) {
            collection.sort = titleAsc;
          } else {
            collection.sort = titleDesc;
          }
          SharedPreferences.getInstance().then((prefs) => prefs.remove('sort'));
        }

        collection.fetchMedia();
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

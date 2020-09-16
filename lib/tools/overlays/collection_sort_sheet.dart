import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/tools/overlays/modal_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionSortSheet extends StatelessWidget {
  final bool isAnimeCollection;

  CollectionSortSheet(this.isAnimeCollection);

  @override
  Widget build(BuildContext context) {
    final collection = isAnimeCollection
        ? Provider.of<AnimeCollection>(context, listen: false)
        : Provider.of<MangaCollection>(context, listen: false);

    final mediaSort = collection.sort;
    final currentIndex = mediaSort.index ~/ 2;
    final currentlyDesc = mediaSort.index % 2 == 0 ? false : true;

    List<String> options = [];
    for (int i = 0; i < MediaListSort.values.length; i += 2) {
      options.add(clarifyEnum(describeEnum(MediaListSort.values[i])));
    }

    return ModalSheet(
      options: options,
      index: currentIndex,
      desc: currentlyDesc,
      onTap: (int index) {
        if (index == currentIndex) {
          if (currentlyDesc) {
            collection.sort = MediaListSort.values[index * 2];
            SharedPreferences.getInstance()
                .then((prefs) => prefs.setInt('sort', index * 2));
          } else {
            collection.sort = MediaListSort.values[index * 2 + 1];
            SharedPreferences.getInstance()
                .then((prefs) => prefs.setInt('sort', index * 2 + 1));
          }
        } else {
          collection.sort = MediaListSort.values[index * 2];
          SharedPreferences.getInstance()
              .then((prefs) => prefs.setInt('sort', index * 2));
        }

        collection.sortCollection();
      },
    );
  }
}

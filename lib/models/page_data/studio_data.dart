import 'package:flutter/foundation.dart';
import 'package:otraku/models/page_data/page_item_data.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/tuple.dart';

class StudioData extends PageItemData {
  final String name;
  final Tuple<List<String>, List<List<BrowseResult>>> media;
  int _nextPage;

  StudioData({
    @required this.name,
    @required this.media,
    @required id,
    @required isFavourite,
    @required favourites,
    @required browsable,
  }) : super(
          id: id,
          isFavourite: isFavourite,
          favourites: favourites,
          browsable: browsable,
        ) {
    _nextPage = 1;
  }

  int get nextPage {
    return _nextPage;
  }

  void appendMedia(List<String> years, List<List<BrowseResult>> anime) {
    if (media.item1.last == years.first) {
      years.removeAt(0);
      media.item2.last.addAll(anime.removeAt(0));
    }

    media.item1.addAll(years);
    media.item2.addAll(anime);

    _nextPage++;
  }
}

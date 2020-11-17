import 'package:otraku/models/sample_data/browse_result.dart';

class StudioConnectionList {
  final List<String> categories;
  final List<List<BrowseResult>> media;
  bool _hasNextPage;
  int _nextPage = 2;

  StudioConnectionList(this.categories, this.media, this._hasNextPage);

  bool get hasNextPage => _hasNextPage;

  int get nextPage => _nextPage;

  int get mediaCount {
    int count = 0;
    for (final list in media) count += list.length;
    return count;
  }

  void append(
    List<String> moreCategories,
    List<List<BrowseResult>> moreMedia,
    bool hasNext,
  ) {
    if (categories.last == moreCategories.first) {
      moreCategories.removeAt(0);
      media.last.addAll(moreMedia.removeAt(0));
    }

    categories.addAll(moreCategories);
    media.addAll(moreMedia);

    _nextPage++;
    _hasNextPage = hasNext;
  }
}

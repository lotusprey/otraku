import 'package:otraku/models/sample_data/browse_result.dart';

class StudioConnectionList {
  final List<String> categories;
  final List<List<BrowseResult>> split;
  bool _hasNextPage;
  int _nextPage = 2;

  StudioConnectionList(this.categories, this.split, this._hasNextPage);

  List<BrowseResult> get joined {
    final List<BrowseResult> joined = [];
    for (final list in split) {
      joined.addAll(list);
    }
    return joined;
  }

  bool get hasNextPage => _hasNextPage;

  int get nextPage => _nextPage;

  int get mediaCount {
    int count = 0;
    for (final list in split) count += list.length;
    return count;
  }

  void append(
    List<String> moreCategories,
    List<List<BrowseResult>> moreMedia,
    bool hasNext,
  ) {
    if (categories.last == moreCategories.first) {
      moreCategories.removeAt(0);
      split.last.addAll(moreMedia.removeAt(0));
    }

    categories.addAll(moreCategories);
    split.addAll(moreMedia);

    _nextPage++;
    _hasNextPage = hasNext;
  }
}

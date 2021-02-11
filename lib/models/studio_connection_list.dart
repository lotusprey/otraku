import 'package:otraku/models/browse_result_model.dart';

class StudioConnectionList {
  final List<String> categories;
  final List<List<BrowseResultModel>> split;
  bool _hasNextPage;
  int _nextPage = 2;

  StudioConnectionList(this.categories, this.split, this._hasNextPage);

  List<BrowseResultModel> get joined {
    final List<BrowseResultModel> joined = [];
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
    List<List<BrowseResultModel>> moreMedia,
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

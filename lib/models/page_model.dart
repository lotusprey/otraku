class PageModel<T> {
  final items = <T>[];
  bool _hasNextPage = true;
  int _nextPage = 1;

  bool get hasNextPage => _hasNextPage;

  int get nextPage => _nextPage;

  void append(List<T> moreItems, [bool hasNext = false]) {
    items.addAll(moreItems);
    _hasNextPage = hasNext;
    _nextPage++;
  }

  void clear() {
    items.clear();
    _hasNextPage = true;
    _nextPage = 1;
  }

  void replace(List<T> moreItems, [bool hasNext = false]) {
    items.clear();
    items.addAll(moreItems);
    _hasNextPage = hasNext;
    _nextPage = 2;
  }
}

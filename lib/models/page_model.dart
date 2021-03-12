class PageModel<T> {
  final List<T> items;
  bool _hasNextPage;
  int _nextPage;

  PageModel(this.items, this._hasNextPage, this._nextPage);

  bool get hasNextPage => _hasNextPage;

  int get nextPage => _nextPage;

  void append(List<T> moreItems, bool hasNext) {
    items.addAll(moreItems);
    _hasNextPage = hasNext;
    _nextPage++;
  }
}

class LoadableList<T> {
  final List<T> items;
  bool _hasNextPage;
  int _nextPage;

  LoadableList(this.items, this._hasNextPage, [this._nextPage = 2]);

  bool get hasNextPage => _hasNextPage;

  int get nextPage => _nextPage;

  void append(List<T> moreItems, bool hasNext) {
    items.addAll(moreItems);
    _hasNextPage = hasNext;
    _nextPage++;
  }
}

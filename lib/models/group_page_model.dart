class GroupPageModel<T> {
  final names = <String>[];
  final groups = <List<T>>[];
  bool _hasNextPage = true;
  int _nextPage = 1;

  bool get hasNextPage => _hasNextPage;

  int get nextPage => _nextPage;

  int get mediaCount {
    int count = 0;
    for (final group in groups) count += group.length;
    return count;
  }

  List<T> get joined {
    final all = <T>[];
    for (final group in groups) all.addAll(group);
    return all;
  }

  void append(
    List<String> moreNames,
    List<List<T>> moreGroups,
    bool hasNext,
  ) {
    if (names.isNotEmpty && names.last == moreNames.first) {
      moreNames.removeAt(0);
      groups.last.addAll(moreGroups.removeAt(0));
    }

    names.addAll(moreNames);
    groups.addAll(moreGroups);

    _nextPage++;
    _hasNextPage = hasNext;
  }

  void clear() {
    names.clear();
    groups.clear();
    _hasNextPage = true;
    _nextPage = 1;
  }
}

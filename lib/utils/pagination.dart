class Pagination<T> {
  const Pagination._({
    required this.items,
    required this.hasNext,
    required this.next,
  });

  factory Pagination() => const Pagination._(items: [], hasNext: true, next: 1);

  factory Pagination.from({
    required List<T> items,
    required bool hasNext,
    int next = 2,
  }) =>
      Pagination._(items: items, hasNext: hasNext, next: next);

  final List<T> items;

  /// If it's possible to load a new page, or the list is complete.
  final bool hasNext;

  /// The index of the next page to be loaded.
  final int next;

  /// Recreate [this] as if a new page has been loaded - append items at the
  /// back and use a new [hasNext]. Note that instead of creating a new list,
  /// [newItems] are appended to the old [items]. This is because [this] is
  /// expected to get discarded.
  Pagination<T> append(List<T> newItems, bool newHasNext) => Pagination._(
        items: items..addAll(newItems),
        hasNext: newHasNext,
        next: next + 1,
      );
}

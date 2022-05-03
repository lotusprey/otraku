class Pages<T> {
  Pages._({required this.items, required this.hasNext, required this.next});

  factory Pages() => Pages._(items: [], hasNext: true, next: 1);

  factory Pages.from({
    required List<T> items,
    required bool hasNext,
    int next = 2,
  }) =>
      Pages._(items: items, hasNext: hasNext, next: next);

  final List<T> items;
  final bool hasNext;
  final int next;

  Pages<T> remakeWith(List<T> newItems, bool newHasNext) => Pages._(
        items: items..addAll(newItems),
        hasNext: newHasNext,
        next: next + 1,
      );
}

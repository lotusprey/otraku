/// Used for pagination.
class Paged<T> {
  const Paged({
    this.items = const [],
    this.hasNext = true,
    this.next = 1,
  });

  final List<T> items;

  /// If it's possible to load a new page, or the list is complete.
  final bool hasNext;

  /// The index of the next page to be loaded.
  final int next;

  /// Recreate with another page loaded.
  Paged<T> withNext(List<T> items, bool hasNext) => Paged(
        items: [...this.items, ...items],
        hasNext: hasNext,
        next: next + 1,
      );
}

/// [Paged] that additionally keeps track of the total amount of items.
class PagedWithTotal<T> extends Paged<T> {
  const PagedWithTotal({
    super.items,
    super.hasNext,
    super.next,
    this.total = 0,
  });

  final int total;

  @override
  PagedWithTotal<T> withNext(List<T> items, bool hasNext, [int? total]) =>
      PagedWithTotal(
        items: [...this.items, ...items],
        hasNext: hasNext,
        next: next + 1,
        total: total ?? this.total,
      );
}

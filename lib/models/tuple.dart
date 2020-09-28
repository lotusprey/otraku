class Tuple<T, U> {
  final T item1;
  final U item2;

  const Tuple(this.item1, this.item2);

  Tuple<T, U> withItem2(U item) => Tuple(item1, item);
}

extension EnumExtension<T extends Enum> on Iterable<T> {
  T? getOrNull(int? index) {
    if (index != null && index >= 0 && index < length) {
      return elementAt(index);
    }

    return null;
  }

  T getOrFirst(int? index) {
    if (index != null && index >= 0 && index < length) {
      return elementAt(index);
    }

    return first;
  }
}
